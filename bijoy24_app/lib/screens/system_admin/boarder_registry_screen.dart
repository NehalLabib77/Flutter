import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../providers/system_admin_provider.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/confirmation_dialog.dart';

class BoarderRegistryScreen extends ConsumerStatefulWidget {
  const BoarderRegistryScreen({super.key});

  @override
  ConsumerState<BoarderRegistryScreen> createState() =>
      _BoarderRegistryScreenState();
}

class _BoarderRegistryScreenState extends ConsumerState<BoarderRegistryScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(boarderRegistryProvider.notifier).fetch());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(boarderRegistryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Boarder Registry')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/system-admin/registry/create'),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Boarder'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or ID...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: state.when(
              data: (boarders) {
                final filtered = _searchQuery.isEmpty
                    ? boarders
                    : boarders
                          .where(
                            (b) =>
                                (b.studentName ?? '').toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                ) ||
                                (b.studentId ?? '').toString().contains(
                                  _searchQuery,
                                ),
                          )
                          .toList();
                if (filtered.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.people_outline,
                    title: 'No Boarders Found',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(boarderRegistryProvider.notifier).fetch(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final b = filtered[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Text(
                              (b.studentName ?? 'B')
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            b.studentName ?? 'Boarder #${b.registryId}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Hall: ${b.hallName ?? 'N/A'} • Room: ${b.roomNumber ?? 'N/A'} • ${b.status ?? 'Active'}',
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (a) => _handleAction(a, b.registryId),
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  'Remove',
                                  style: TextStyle(color: AppColors.error),
                                ),
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
                message: 'Failed to load boarder registry',
                onRetry: () =>
                    ref.read(boarderRegistryProvider.notifier).fetch(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAction(String action, int id) {
    switch (action) {
      case 'edit':
        context.push('/system-admin/registry/edit/$id');
        break;
      case 'delete':
        _deleteBoarder(id);
        break;
    }
  }

  Future<void> _deleteBoarder(int id) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Remove Boarder',
      message: 'Remove this boarder from the registry?',
      confirmText: 'Remove',
      confirmColor: AppColors.error,
    );
    if (confirmed == true) {
      await ref.read(boarderRegistryProvider.notifier).delete(id);
    }
  }
}
