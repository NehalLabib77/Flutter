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

class BoarderRegistryScreen extends ConsumerStatefulWidget {
  const BoarderRegistryScreen({super.key});

  @override
  ConsumerState<BoarderRegistryScreen> createState() =>
      _BoarderRegistryScreenState();
}

class _BoarderRegistryScreenState extends ConsumerState<BoarderRegistryScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(boarderRegistryProvider.notifier).fetch());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(boarderRegistryProvider);

    return Scaffold(
      appBar: const GradientAppBar(title: 'Boarder Registry'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/system-admin/boarders/create'),
        icon: const Icon(Icons.person_add_alt_rounded),
        label: const Text('Add Boarder'),
      ),
      body: state.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorRetryWidget(
          message: 'Failed to load registry',
          onRetry: () => ref.read(boarderRegistryProvider.notifier).fetch(),
        ),
        data: (boarders) {
          if (boarders.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.people_alt_rounded,
              title: 'No Boarders',
              subtitle: 'Start adding boarders to the registry.',
              actionLabel: 'Add Boarder',
              onAction: () => context.go('/system-admin/boarders/create'),
            );
          }

          final filtered = _search.isEmpty
              ? boarders
              : boarders.where((b) {
                  final q = _search.toLowerCase();
                  return (b.boarderNo.toLowerCase().contains(q)) ||
                      (b.studentName?.toLowerCase().contains(q) ?? false) ||
                      (b.studentId?.toLowerCase().contains(q) ?? false);
                }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name, boarder no, or ID...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _search.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () => setState(() => _search = ''),
                          )
                        : null,
                  ),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      ref.read(boarderRegistryProvider.notifier).fetch(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final b = filtered[i];
                      return AppCard(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.12,
                            ),
                            child: Text(
                              b.studentName?.isNotEmpty == true
                                  ? b.studentName![0].toUpperCase()
                                  : '#',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          title: Text(
                            b.studentName ?? 'Unnamed',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Boarder #${b.boarderNo}  •  ${b.department ?? ''}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  if (b.hallName != null)
                                    Flexible(
                                      child: Text(
                                        '${b.hallName} ${b.roomNumber != null ? "/ ${b.roomNumber}" : ""}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  StatusBadge(status: b.status, fontSize: 10),
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
                                  '/system-admin/boarders/${b.registryId}/edit',
                                );
                              } else if (v == 'delete') {
                                _confirmDelete(
                                  b.registryId,
                                  b.studentName ?? 'Boarder',
                                );
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(int id, String name) async {
    final ok = await showConfirmationDialog(
      context,
      title: 'Delete Boarder',
      message: 'Remove "$name" from the registry?',
      confirmText: 'Delete',
      confirmColor: Colors.red,
    );
    if (ok == true && mounted) {
      await ref.read(boarderRegistryProvider.notifier).delete(id);
    }
  }
}
