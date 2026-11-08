import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'sync_dao.g.dart';

@DriftAccessor(tables: [SyncQueue, SyncConflicts])
class SyncDao extends DatabaseAccessor<AppDatabase> with _$SyncDaoMixin {
  SyncDao(super.db);

  // Enqueue a local mutation into sync queue (can be called inside an existing transaction)
  Future<void> enqueue({
    required String targetTable,
    required String recordId,
    required String operation,
    required String payloadJson,
    required String idempotencyKey,
    int clientRevision = 1,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final existing = await (select(syncQueue)
          ..where((t) => t.idempotencyKey.equals(idempotencyKey)))
        .getSingleOrNull();

    if (existing != null) {
      await (update(syncQueue)..where((t) => t.id.equals(existing.id))).write(
        SyncQueueCompanion(
          operation: Value(operation),
          payloadJson: Value(payloadJson),
          clientRevision: Value(clientRevision),
          createdAt: Value(now),
          status: const Value('pending'),
          errorMessage: const Value(null),
        ),
      );
    } else {
      await into(syncQueue).insert(
        SyncQueueCompanion.insert(
          targetTable: targetTable,
          recordId: recordId,
          operation: operation,
          payloadJson: payloadJson,
          idempotencyKey: idempotencyKey,
          clientRevision: Value(clientRevision),
          createdAt: now,
          status: const Value('pending'),
        ),
      );
    }
  }

  // Get all pending queue items (excluding permanent failures with retry_count >= 10)
  Future<List<SyncQueueData>> getPendingItems({int limit = 50}) {
    return (select(syncQueue)
          ..where((t) =>
              (t.status.equals('pending') | t.status.equals('failed')) &
              t.retryCount.isSmallerThanValue(10))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt)])
          ..limit(limit))
        .get();
  }

  // Get recent queue items for the Sync Outbox Inspector UI
  Future<List<SyncQueueData>> getAllQueueItems({int limit = 100}) {
    return (select(syncQueue)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  // Watch count of pending items for live UI badge
  Stream<int> watchPendingCount() {
    final countExpr = syncQueue.id.count();
    return (selectOnly(syncQueue)
          ..addColumns([countExpr])
          ..where(syncQueue.status.equals('pending') | syncQueue.status.equals('failed')))
        .map((row) => row.read(countExpr) ?? 0)
        .watchSingle();
  }

  // Mark items as synced
  Future<void> markSynced(List<int> queueIds) async {
    if (queueIds.isEmpty) return;
    await (update(syncQueue)..where((t) => t.id.isIn(queueIds)))
        .write(const SyncQueueCompanion(status: Value('synced'), errorMessage: Value(null)));
  }

  // Mark item as failed
  Future<void> markFailed(int queueId, String error) async {
    await customUpdate(
      'UPDATE sync_queue SET status = ?, retry_count = retry_count + 1, error_message = ? WHERE id = ?',
      variables: [
        Variable.withString('failed'),
        Variable.withString(error),
        Variable.withInt(queueId),
      ],
      updates: {syncQueue},
    );
  }

  // Reset failed items for manual retry
  Future<void> resetFailedItems() async {
    await customUpdate(
      'UPDATE sync_queue SET status = ?, retry_count = 0, error_message = NULL WHERE status = ?',
      variables: [
        Variable.withString('pending'),
        Variable.withString('failed'),
      ],
      updates: {syncQueue},
    );
  }

  // Purge already synced items
  Future<int> purgeSynced() {
    return (delete(syncQueue)..where((t) => t.status.equals('synced'))).go();
  }

  // Record a sync conflict
  Future<void> recordConflict({
    required String id,
    required String recordId,
    required String tableName,
    required String studentId,
    required String date,
    required String localStatus,
    required String serverStatus,
    required String conflictReason,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await into(syncConflicts).insertOnConflictUpdate(
      SyncConflictsCompanion.insert(
        id: id,
        recordId: recordId,
        targetTableName: tableName,
        studentId: studentId,
        date: date,
        localStatus: localStatus,
        serverStatus: serverStatus,
        conflictReason: conflictReason,
        status: const Value('unresolved'),
        createdAt: now,
      ),
    );
  }

  // Get unresolved conflicts
  Future<List<SyncConflictModel>> getUnresolvedConflicts() async {
    final rows = await (select(syncConflicts)
          ..where((t) => t.status.equals('unresolved'))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    return rows
        .map((entry) => SyncConflictModel(
              id: entry.id,
              recordId: entry.recordId,
              tableName: entry.targetTableName,
              studentId: entry.studentId,
              date: entry.date,
              localStatus: entry.localStatus,
              serverStatus: entry.serverStatus,
              conflictReason: entry.conflictReason,
              status: entry.status,
              createdAt: entry.createdAt,
            ))
        .toList();
  }

  // Resolve a sync conflict
  Future<void> resolveConflict(String conflictId, String resolutionStatus) async {
    await (update(syncConflicts)..where((t) => t.id.equals(conflictId))).write(
      SyncConflictsCompanion(
        status: Value(resolutionStatus),
      ),
    );
  }
}
