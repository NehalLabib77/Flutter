import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../providers/system_admin_provider.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/confirmation_dialog.dart';

class ManageHallAdminsScreen extends ConsumerStatefulWidget {
  const ManageHallAdminsScreen({super.key});

  @override
  ConsumerState<ManageHallAdminsScreen> createState() =>
      _ManageHallAdminsScreenState();
}

class _ManageHallAdminsScreenState
    extends ConsumerState<ManageHallAdminsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(sysAdminHallAdminsProvider.notifier).fetch(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sysAdminHallAdminsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Hall Administrators')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/system-admin/admins/create'),
        icon: const Icon(Icons.person_add),
        label: const Text('New Admin'),
      ),
      body: state.when(
        data: (admins) {
          if (admins.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.admin_panel_settings_outlined,
              title: 'No Hall Admins',
              subtitle: 'Tap + to create a new hall admin',
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(sysAdminHallAdminsProvider.notifier).fetch(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: admins.length,
              itemBuilder: (ctx, i) {
                final admin = admins[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primary,
                              child: Text(
                                (admin.adminName ?? 'A')
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    admin.adminName ?? 'Admin #${admin.hallAdminId}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    admin.email ?? '',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (a) =>
                                  _handleAction(a, admin.hallAdminId),
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem(
                                  value: 'token',
                                  child: Text('View Token'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(color: AppColors.error),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.apartment,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              admin.hallName ??
                                  'Hall #${admin.hallId ?? 'N/A'}',
                              style: const TextStyle(fontSize: 13),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.phone,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              admin.phone ?? 'N/A',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (_, __) => ErrorRetryWidget(
          message: 'Failed to load hall admins',
          onRetry: () => ref.read(sysAdminHallAdminsProvider.notifier).fetch(),
        ),
      ),
    );
  }

  void _handleAction(String action, int adminId) {
    switch (action) {
      case 'edit':
        context.push('/system-admin/admins/edit/$adminId');
        break;
      case 'token':
        _showToken(adminId);
        break;
      case 'delete':
        _deleteAdmin(adminId);
        break;
    }
  }

  Future<void> _showToken(int adminId) async {
    // In production, fetch token from API
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Registration Token'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Share this 12-character token with the hall admin:'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: SelectableText(
                'TOKEN-$adminId-XY',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAdmin(int adminId) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Delete Hall Admin',
      message: 'Remove this hall administrator permanently?',
      confirmText: 'Delete',
      confirmColor: AppColors.error,
    );
    if (confirmed == true) {
      await ref.read(sysAdminHallAdminsProvider.notifier).delete(adminId);
    }
  }
}
