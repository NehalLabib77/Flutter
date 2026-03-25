import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../providers/system_admin_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state_widget.dart';
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
      appBar: const GradientAppBar(title: 'Hall Admins'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/system-admin/hall-admins/create'),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Admin'),
      ),
      body: state.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorRetryWidget(
          message: 'Failed to load admins',
          onRetry: () => ref.read(sysAdminHallAdminsProvider.notifier).fetch(),
        ),
        data: (admins) {
          if (admins.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.admin_panel_settings_rounded,
              title: 'No Admins Yet',
              subtitle: 'Add your first hall admin to get started.',
              actionLabel: 'Add Admin',
              onAction: () => context.go('/system-admin/hall-admins/create'),
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
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(
                        alpha: 0.12,
                      ),
                      child: Text(
                        admin.adminName.isNotEmpty
                            ? admin.adminName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    title: Text(
                      admin.adminName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (admin.email != null)
                          Text(
                            admin.email!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (admin.hallName != null)
                              Flexible(
                                child: Text(
                                  admin.hallName!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            const SizedBox(width: 8),
                            StatusBadge(status: admin.status, fontSize: 10),
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            dense: true,
                            leading: Icon(Icons.edit_rounded, size: 20),
                            title: Text('Edit'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.delete_rounded,
                              size: 20,
                              color: Colors.red,
                            ),
                            title: Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                      onSelected: (v) {
                        if (v == 'edit') {
                          context.go(
                            '/system-admin/hall-admins/${admin.hallAdminId}/edit',
                          );
                        } else if (v == 'delete') {
                          _confirmDelete(admin.hallAdminId, admin.adminName);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(int id, String name) async {
    final ok = await showConfirmationDialog(
      context,
      title: 'Delete Admin',
      message: 'Remove "$name" permanently? This action cannot be undone.',
      confirmText: 'Delete',
      confirmColor: Colors.red,
    );
    if (ok == true && mounted) {
      await ref.read(sysAdminHallAdminsProvider.notifier).delete(id);
    }
  }
}
