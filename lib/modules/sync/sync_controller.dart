import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../core/database/app_database.dart';
import '../../data/repositories/sync_repository.dart';
import '../attendance/attendance_controller.dart';
import '../admin/admin_controller.dart';
import '../auth/auth_controller.dart';
import '../students/students_controller.dart';

/// Firebase-Grade Offline & Cloud Sync Controller
/// 
/// Operates on a seamless Local-First + Transparent Cloud Sync paradigm:
/// 1. Instant optimistic local writes (0ms lag in Drift SQLite).
/// 2. Micro-debounced automatic background push to Cloudflare D1 (no user intervention required).
/// 3. Automatic silent sync upon network reconnect (via connectivity_plus).
/// 4. App lifecycle resume re-sync (WidgetsBindingObserver).
/// 5. Graceful offline queuing without intrusive modal errors.
class SyncController extends GetxController with WidgetsBindingObserver {
  final SyncRepository syncRepository;

  SyncController(this.syncRepository);

  final RxInt pendingCount = 0.obs;
  final RxBool isSyncing = false.obs;
  final Rx<SyncStatus> status = SyncStatus.idle.obs;
  final RxString lastSyncMessage = 'All records stored locally in SQLite'.obs;
  final Rx<DateTime?> lastSyncedAt = Rx<DateTime?>(null);
  final RxBool isOnlineNetwork = true.obs;

  final RxList<SyncQueueData> queueItems = <SyncQueueData>[].obs;
  final RxList<SyncConflictModel> conflicts = <SyncConflictModel>[].obs;

  StreamSubscription? _sub;
  StreamSubscription? _connectivitySub;
  Timer? _autoSyncTimer;
  Timer? _debounceTimer;
  bool _hasPendingSyncRequest = false;
  bool _pendingRequestNeedsPull = false;
  DateTime? _lastPullTime;
  int _consecutiveFailures = 0;

  /// Minimum interval between automatic background D1 delta pulls (5 minutes)
  /// to eliminate unnecessary Cloudflare D1 read consumption while keeping
  /// multi-device schools synchronized.
  static const Duration _minAutoPullInterval = Duration(minutes: 5);

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    // Wire repository callback to this controller's debounce engine
    syncRepository.onMutationEnqueued = notifyMutation;

    _sub = syncRepository.watchPendingCount().listen((count) {
      pendingCount.value = count;
      if (count == 0 && status.value != SyncStatus.syncing) {
        status.value = SyncStatus.success;
      } else if (count > 0 && status.value != SyncStatus.syncing) {
        status.value = isOnlineNetwork.value ? SyncStatus.idle : SyncStatus.offline;
      }
      refreshQueueAndConflicts();
    });

    refreshQueueAndConflicts();

    // Listen to real-time network connectivity changes (important for rural areas)
    _connectivitySub = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final isConnected = results.any((r) => r != ConnectivityResult.none);
      final wasOffline = !isOnlineNetwork.value;
      isOnlineNetwork.value = isConnected;
      if (isConnected && wasOffline) {
        _consecutiveFailures = 0;
        // Flush any queued offline mutations and pull delta if interval elapsed
        final shouldPull = _shouldAutoPull();
        syncNow(silent: true, pushOnly: !shouldPull);
      } else if (!isConnected) {
        if (pendingCount.value > 0) {
          status.value = SyncStatus.offline;
        }
      }
    });

    // Rural-friendly background heartbeat:
    // Checks every 3 minutes. Only performs network I/O if there are pending local
    // mutations in SQLite outbox OR if the 5-minute delta pull window has elapsed.
    _autoSyncTimer = Timer.periodic(const Duration(minutes: 3), (_) {
      if (!isSyncing.value && isOnlineNetwork.value) {
        if (pendingCount.value > 0) {
          syncNow(silent: true, pushOnly: !_shouldAutoPull());
        } else if (_shouldAutoPull()) {
          syncNow(silent: true);
        }
      }
    });

    // Trigger an initial silent delta sync on launch
    Future.delayed(const Duration(milliseconds: 600), () {
      syncNow(silent: true);
    });
  }

  bool _shouldAutoPull() {
    if (_lastPullTime == null) return true;
    return DateTime.now().difference(_lastPullTime!) >= _minAutoPullInterval;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // When returning to foreground, push pending mutations immediately,
      // and only pull from D1 if at least 2 minutes have passed since last pull.
      final shouldPull = _lastPullTime == null ||
          DateTime.now().difference(_lastPullTime!) >= const Duration(minutes: 2);
      if (pendingCount.value > 0 || shouldPull) {
        syncNow(silent: true, pushOnly: !shouldPull);
      }
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    syncRepository.onMutationEnqueued = null;
    _connectivitySub?.cancel();
    _debounceTimer?.cancel();
    _sub?.cancel();
    _autoSyncTimer?.cancel();
    super.onClose();
  }

  /// Coalesced Write-Through Outbox Flush:
  /// Debounces rapid client mutations (e.g. a teacher marking 30 students in a row)
  /// by 1500ms and flushes all pending mutations in a SINGLE batch POST to Cloudflare D1
  /// without triggering redundant 12-table pull queries on every tap.
  void notifyMutation({Duration debounce = const Duration(milliseconds: 1500)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () {
      if (isSyncing.value) {
        _hasPendingSyncRequest = true;
      } else {
        syncNow(silent: true, pushOnly: true);
      }
    });
  }

  Future<void> refreshQueueAndConflicts() async {
    queueItems.assignAll(await syncRepository.getAllQueueItems(limit: 50));
    conflicts.assignAll(await syncRepository.getUnresolvedConflicts());
  }

  Future<void> retryFailedOperations() async {
    _consecutiveFailures = 0;
    await syncRepository.resetFailedItems();
    await refreshQueueAndConflicts();
    await syncNow();
  }

  Future<void> resolveConflict(String conflictId, String resolution) async {
    await syncRepository.resolveConflict(conflictId, resolution);
    await refreshQueueAndConflicts();
    Get.snackbar('Conflict Resolved', 'Sync conflict marked as $resolution.');
  }

  Future<void> syncNow({
    bool silent = false,
    bool forceFull = false,
    bool pushOnly = false,
  }) async {
    if (isSyncing.value) {
      _hasPendingSyncRequest = true;
      if (!pushOnly) _pendingRequestNeedsPull = true;
      return;
    }

    // Exponential backoff guard for flaky rural 2G/3G networks when silent
    if (silent && _consecutiveFailures >= 3) {
      final backoffSeconds = (1 << _consecutiveFailures.clamp(1, 6)) * 5;
      if (lastSyncedAt.value != null &&
          DateTime.now().difference(lastSyncedAt.value!).inSeconds < backoffSeconds) {
        return;
      }
    }

    try {
      isSyncing.value = true;
      status.value = SyncStatus.syncing;
      lastSyncMessage.value = 'Synchronizing with Cloudflare D1...';

      final auth = Get.find<AuthController>();
      final schoolId = auth.currentUser.value?.schoolId;
      if (schoolId == null || schoolId.isEmpty) {
        return;
      }

      final pushed = await syncRepository.pushPending();
      int pulled = 0;
      if (!pushOnly || forceFull) {
        pulled = await syncRepository.pullLatest(schoolId, forceFull: forceFull);
        _lastPullTime = DateTime.now();
      }
      if (pushed > 0) {
        await syncRepository.purgeCompleted();
      }
      await refreshQueueAndConflicts();

      if (pulled > 0 || forceFull) {
        if (Get.isRegistered<AttendanceController>()) {
          final attCtrl = Get.find<AttendanceController>();
          if (attCtrl.classesList.isEmpty) {
            await attCtrl.loadClasses();
          } else {
            await attCtrl.loadStudentsAndAttendance();
          }
        }
        if (Get.isRegistered<StudentsController>()) {
          await Get.find<StudentsController>().loadStudents();
        }
        if (Get.isRegistered<AdminController>()) {
          await Get.find<AdminController>().loadAllAdminData();
        }
      }

      _consecutiveFailures = 0;
      lastSyncedAt.value = DateTime.now();
      status.value = SyncStatus.success;
      final timeStr = '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';
      lastSyncMessage.value = 'Cloud Synced at $timeStr';

      if (!silent) {
        Get.snackbar(
          'Synchronization Complete',
          'Pushed $pushed local change(s) and merged $pulled cloud update(s).',
        );
      }
    } catch (e) {
      _consecutiveFailures++;
      status.value = SyncStatus.offline;
      lastSyncMessage.value = 'Offline: changes safely queued in local SQLite outbox';
      await refreshQueueAndConflicts();
      if (!silent) {
        Get.snackbar(
          'Working Offline',
          'Changes are safely persisted in SQLite outbox and will sync automatically when connectivity returns.',
        );
      }
    } finally {
      isSyncing.value = false;
      if (_hasPendingSyncRequest) {
        final needsPull = _pendingRequestNeedsPull;
        _hasPendingSyncRequest = false;
        _pendingRequestNeedsPull = false;
        Timer.run(() => syncNow(silent: true, pushOnly: !needsPull));
      }
    }
  }
}
