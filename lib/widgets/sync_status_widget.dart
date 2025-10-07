import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class SyncStatusWidget extends StatelessWidget {
  final bool showDetails;

  const SyncStatusWidget({super.key, this.showDetails = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(appState).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _getStatusColor(appState), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getStatusIcon(appState),
                size: 14,
                color: _getStatusColor(appState),
              ),
              const SizedBox(width: 4),
              Text(
                _getStatusText(appState),
                style: TextStyle(
                  fontSize: 12,
                  color: _getStatusColor(appState),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (showDetails && appState.pendingSyncItems > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${appState.pendingSyncItems}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(AppState appState) {
    if (appState.isSyncing) {
      return Colors.blue;
    } else if (!appState.isOnline) {
      return Colors.grey;
    } else if (appState.pendingSyncItems > 0) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  IconData _getStatusIcon(AppState appState) {
    if (appState.isSyncing) {
      return Icons.sync;
    } else if (!appState.isOnline) {
      return Icons.cloud_off;
    } else if (appState.pendingSyncItems > 0) {
      return Icons.cloud_upload;
    } else {
      return Icons.cloud_done;
    }
  }

  String _getStatusText(AppState appState) {
    if (appState.isSyncing) {
      return 'Syncing...';
    } else if (!appState.isOnline) {
      return 'Offline';
    } else if (appState.pendingSyncItems > 0) {
      return 'Pending';
    } else {
      return 'Synced';
    }
  }
}

class SyncButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const SyncButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return IconButton(
          onPressed:
              appState.isSyncing || !appState.isOnline
                  ? null
                  : onPressed ?? () => _performSync(context, appState),
          icon:
              appState.isSyncing
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : Icon(
                    Icons.sync,
                    color: appState.isOnline ? Colors.blue : Colors.grey,
                  ),
          tooltip:
              appState.isSyncing
                  ? 'Syncing...'
                  : !appState.isOnline
                  ? 'No internet connection'
                  : 'Sync with server',
        );
      },
    );
  }

  Future<void> _performSync(BuildContext context, AppState appState) async {
    try {
      final result = await appState.performFullSync();

      if (context.mounted) {
        final message =
            result['success'] == true
                ? '✅ Sync completed successfully'
                : '❌ ${result['message'] ?? 'Sync failed'}';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor:
                result['success'] == true ? Colors.green : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

class NetworkStatusBar extends StatelessWidget {
  const NetworkStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        if (appState.isOnline) {
          return const SizedBox.shrink(); // Hide when online
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.orange.shade100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 16, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Text(
                appState.networkStatus,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SyncStatsDialog extends StatelessWidget {
  const SyncStatsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.analytics, color: Colors.blue),
              SizedBox(width: 8),
              Text('Sync Statistics'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatRow(
                'Network Status',
                appState.networkStatus,
                appState.isOnline ? Icons.check_circle : Icons.error,
              ),
              const SizedBox(height: 8),
              _buildStatRow(
                'Sync Status',
                appState.isSyncing ? 'Syncing...' : 'Ready',
                appState.isSyncing ? Icons.sync : Icons.done,
              ),
              const SizedBox(height: 8),
              _buildStatRow(
                'Pending Items',
                '${appState.pendingSyncItems}',
                appState.pendingSyncItems > 0 ? Icons.upload : Icons.done_all,
              ),
              const SizedBox(height: 8),
              _buildStatRow(
                'Last Sync',
                appState.lastSyncTime != null
                    ? _formatLastSync(appState.lastSyncTime!)
                    : 'Never',
                Icons.schedule,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            if (appState.isOnline && !appState.isSyncing)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  appState.performFullSync();
                },
                child: const Text('Sync Now'),
              ),
          ],
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
        Expanded(child: Text(value, style: TextStyle(color: Colors.grey[700]))),
      ],
    );
  }

  String _formatLastSync(DateTime lastSync) {
    final now = DateTime.now();
    final difference = now.difference(lastSync);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
