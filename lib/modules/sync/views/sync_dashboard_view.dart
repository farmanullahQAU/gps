import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../sync_controller.dart';
import '../../../data/repositories/sync_repository.dart';

class SyncDashboardView extends StatelessWidget {
  const SyncDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SyncController>();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Cloud Sync & Outbox Inspector'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Outbox',
            onPressed: () => controller.refreshQueueAndConflicts(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Status Card
                  Obx(() {
                    final pending = controller.pendingCount.value;
                    final isSyncing = controller.isSyncing.value;
                    final status = controller.status.value;

                    Color bg = Colors.green.shade50;
                    Color border = Colors.green.shade700;
                    IconData icon = Icons.cloud_done_rounded;
                    String title = 'All Changes Synchronized';

                    if (isSyncing) {
                      bg = Colors.blue.shade50;
                      border = Colors.blue.shade700;
                      icon = Icons.sync_rounded;
                      title = 'Synchronizing with Cloudflare D1...';
                    } else if (pending > 0) {
                      bg = Colors.amber.shade50;
                      border = Colors.amber.shade800;
                      icon = Icons.cloud_upload_rounded;
                      title = '$pending Operation(s) Queued in Outbox';
                    } else if (status == SyncStatus.offline) {
                      bg = Colors.orange.shade50;
                      border = Colors.orange.shade800;
                      icon = Icons.cloud_off_rounded;
                      title = 'Offline Mode Active';
                    }

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: border, width: 1.8),
                      ),
                      child: Column(
                        children: [
                          Icon(icon, size: 44, color: border),
                          const SizedBox(height: 10),
                          Text(
                            title,
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: border),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.lastSyncMessage.value,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                            textAlign: TextAlign.center,
                          ),
                          if (controller.lastSyncedAt.value != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Last Synced: ${DateFormat('hh:mm:ss a, dd MMM yyyy').format(controller.lastSyncedAt.value!)}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 18),

                  // 2. Conflict Resolution Section (if any conflicts detected)
                  Obx(() {
                    if (controller.conflicts.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sync Conflicts Requiring Review (${controller.conflicts.length})',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                        const SizedBox(height: 8),
                        ...controller.conflicts.map(
                          (c) => Card(
                            color: Colors.red.shade50,
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(
                                '${c.tableName} • Date: ${c.date}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              subtitle: Text(
                                'Local: ${c.localStatus.toUpperCase()} vs Server: ${c.serverStatus.toUpperCase()}\n${c.conflictReason}',
                                style: const TextStyle(fontSize: 11.5),
                              ),
                              trailing: TextButton(
                                onPressed: () => controller.resolveConflict(c.id, 'resolved_accept_server'),
                                child: const Text('Acknowledge'),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  }),

                  // 3. Transactional Outbox Queue Inspector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Transactional Outbox Queue (SQLite)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.replay_rounded, size: 15),
                        label: const Text('Retry Failed', style: TextStyle(fontSize: 12)),
                        onPressed: () => controller.retryFailedOperations(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Obx(() {
                    if (controller.queueItems.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Center(
                          child: Text(
                            'Outbox queue is clean. All local operations have been synchronized.',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.queueItems.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 6),
                      itemBuilder: (ctx, i) {
                        final item = controller.queueItems[i];
                        final isFailed = item.status == 'failed';
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isFailed ? Colors.red.shade300 : AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isFailed ? Icons.error_outline : Icons.schedule_send_rounded,
                                color: isFailed ? Colors.red : AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${item.operation} • ${item.targetTable}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                                    ),
                                    Text(
                                      'Key: ${item.idempotencyKey} • Rev: v${item.clientRevision}',
                                      style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600, fontFamily: 'monospace'),
                                    ),
                                    if (item.errorMessage != null)
                                      Text(
                                        'Retry #${item.retryCount}: ${item.errorMessage}',
                                        style: const TextStyle(fontSize: 10, color: Colors.red),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isFailed ? Colors.red.shade50 : Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: isFailed ? Colors.red.shade800 : Colors.amber.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),

          // Bottom Automatic Sync Notice & Optional Force Refresh
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bolt_rounded, size: 16, color: Color(0xFF15803D)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Live Auto-Sync Active: All changes save instantly and sync automatically without manual steps.',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Obx(() {
                  final syncing = controller.isSyncing.value;
                  return SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryDark),
                        foregroundColor: AppColors.primaryDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: syncing
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: AppColors.primaryDark, strokeWidth: 2))
                          : const Icon(Icons.sync_rounded, size: 18),
                      label: Text(
                        syncing ? 'SYNCHRONIZING...' : 'FORCE REFRESH NOW (OPTIONAL)',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      onPressed: syncing ? null : () => controller.syncNow(),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
