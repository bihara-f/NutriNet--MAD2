import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/sync_status_widget.dart';

class ApiIntegrationPage extends StatefulWidget {
  const ApiIntegrationPage({super.key});

  @override
  State<ApiIntegrationPage> createState() => _ApiIntegrationPageState();
}

class _ApiIntegrationPageState extends State<ApiIntegrationPage> {
  Map<String, dynamic>? _syncStats;

  @override
  void initState() {
    super.initState();
    _loadSyncStats();
  }

  Future<void> _loadSyncStats() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final stats = await appState.getSyncStats();
    setState(() {
      _syncStats = stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Integration'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          const SyncButton(),
          IconButton(
            onPressed: () => _showSyncStatsDialog(context),
            icon: const Icon(Icons.info_outline),
            tooltip: 'Sync Statistics',
          ),
        ],
      ),
      body: Column(
        children: [
          // Network status bar
          const NetworkStatusBar(),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Overview Card
                  _buildStatusCard(),

                  const SizedBox(height: 20),

                  // API Integration Features
                  _buildFeaturesCard(),

                  const SizedBox(height: 20),

                  // Manual Sync Controls
                  _buildSyncControlsCard(),

                  const SizedBox(height: 20),

                  // Laravel Backend Configuration
                  _buildBackendConfigCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.cloud, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text(
                      'API Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const SyncStatusWidget(showDetails: true),
                  ],
                ),
                const SizedBox(height: 16),

                // Network Status
                _buildStatusRow(
                  'Network Status',
                  appState.networkStatus,
                  appState.isOnline ? Colors.green : Colors.red,
                ),

                // Sync Status
                _buildStatusRow(
                  'Sync Status',
                  appState.isSyncing ? 'Syncing...' : 'Ready',
                  appState.isSyncing ? Colors.blue : Colors.green,
                ),

                // Pending Items
                _buildStatusRow(
                  'Pending Sync Items',
                  '${appState.pendingSyncItems}',
                  appState.pendingSyncItems > 0 ? Colors.orange : Colors.green,
                ),

                // Last Sync
                _buildStatusRow(
                  'Last Sync',
                  appState.lastSyncTime != null
                      ? _formatDateTime(appState.lastSyncTime!)
                      : 'Never',
                  Colors.grey,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.integration_instructions, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Integration Features',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildFeatureItem(
              Icons.storage,
              'SQLite Offline Storage',
              'Complete offline-first architecture with local database',
              Colors.blue,
            ),

            _buildFeatureItem(
              Icons.sync,
              'Two-way Synchronization',
              'Upload local changes and download server updates',
              Colors.orange,
            ),

            _buildFeatureItem(
              Icons.cloud_queue,
              'Sync Queue Management',
              'Automatic retry and conflict resolution',
              Colors.purple,
            ),

            _buildFeatureItem(
              Icons.network_check,
              'Network Monitoring',
              'Automatic sync when connection is restored',
              Colors.green,
            ),

            _buildFeatureItem(
              Icons.security,
              'Secure API Calls',
              'Token-based authentication with secure storage',
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncControlsCard() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.control_point, color: Colors.indigo),
                    SizedBox(width: 8),
                    Text(
                      'Manual Sync Controls',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Full Sync Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        appState.isSyncing || !appState.isOnline
                            ? null
                            : () => _performFullSync(context, appState),
                    icon:
                        appState.isSyncing
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.sync),
                    label: const Text('Full Sync'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Upload Only Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        appState.isSyncing ||
                                !appState.isOnline ||
                                appState.pendingSyncItems == 0
                            ? null
                            : () => _uploadChanges(context, appState),
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Upload Changes Only'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Download Only Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        appState.isSyncing || !appState.isOnline
                            ? null
                            : () => _downloadUpdates(context, appState),
                    icon: const Icon(Icons.cloud_download),
                    label: const Text('Download Updates Only'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Retry Failed Button
                if (_syncStats != null && _syncStats!['failed'] > 0)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _retryFailedSync(context, appState),
                      icon: const Icon(Icons.refresh),
                      label: Text(
                        'Retry ${_syncStats!['failed']} Failed Items',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackendConfigCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.settings_applications, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text(
                  'Laravel Backend Configuration',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text(
              'To connect to your Laravel backend, configure the following:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 12),

            _buildConfigItem(
              '1. Update API Base URL',
              'lib/services/api_service.dart → baseUrl',
              'Replace with your Laravel server URL',
            ),

            _buildConfigItem(
              '2. Authentication Endpoints',
              '/api/auth/login, /api/auth/register',
              'Laravel Sanctum or Passport setup',
            ),

            _buildConfigItem(
              '3. Data Endpoints',
              '/api/packages, /api/diet-plans, /api/cart',
              'CRUD operations for app data',
            ),

            _buildConfigItem(
              '4. Sync Endpoint',
              '/api/sync',
              'Bulk data synchronization',
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.amber),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your app currently works fully offline. The sync functionality will activate when you connect to your Laravel backend.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigItem(String title, String code, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              code,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showSyncStatsDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const SyncStatsDialog());
  }

  Future<void> _performFullSync(BuildContext context, AppState appState) async {
    final result = await appState.performFullSync();
    await _loadSyncStats(); // Refresh stats
    _showSyncResult(context, result, 'Full Sync');
  }

  Future<void> _uploadChanges(BuildContext context, AppState appState) async {
    final result = await appState.uploadChanges();
    await _loadSyncStats(); // Refresh stats
    _showSyncResult(context, result, 'Upload');
  }

  Future<void> _downloadUpdates(BuildContext context, AppState appState) async {
    final result = await appState.downloadUpdates();
    await _loadSyncStats(); // Refresh stats
    _showSyncResult(context, result, 'Download');
  }

  Future<void> _retryFailedSync(BuildContext context, AppState appState) async {
    final count = await appState.retryFailedSync();
    await _loadSyncStats(); // Refresh stats

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reset $count failed items for retry'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _showSyncResult(
    BuildContext context,
    Map<String, dynamic> result,
    String operation,
  ) {
    if (context.mounted) {
      final message =
          result['success'] == true
              ? '✅ $operation completed successfully'
              : '❌ $operation failed: ${result['message'] ?? 'Unknown error'}';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              result['success'] == true ? Colors.green : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
