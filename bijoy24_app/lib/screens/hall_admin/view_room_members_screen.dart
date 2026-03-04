import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../providers/hall_admin_provider.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';

class ViewRoomMembersScreen extends ConsumerStatefulWidget {
  final int roomId;
  const ViewRoomMembersScreen({super.key, required this.roomId});

  @override
  ConsumerState<ViewRoomMembersScreen> createState() =>
      _ViewRoomMembersScreenState();
}

class _ViewRoomMembersScreenState extends ConsumerState<ViewRoomMembersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(hallAdminAssignmentsProvider.notifier).fetch(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hallAdminAssignmentsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Room ${widget.roomId} Members')),
      body: state.when(
        data: (assignments) {
          final members = assignments
              .where(
                (a) =>
                    a.roomIdentity == widget.roomId.toString() &&
                    a.status == 'Active',
              )
              .toList();
          if (members.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.people_outline,
              title: 'No Members Assigned',
              subtitle: 'This room currently has no occupants',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: members.length,
            itemBuilder: (ctx, i) {
              final m = members[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text(
                      (m.studentName ?? 'S').substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    m.studentName ?? 'Student #${m.studentId}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${m.faculty ?? 'N/A'} \u2022 Since ${m.assignmentDate.toString().split(' ')[0]}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
        loading: () => const LoadingWidget(),
        error: (_, __) => ErrorRetryWidget(
          message: 'Failed to load room members',
          onRetry: () =>
              ref.read(hallAdminAssignmentsProvider.notifier).fetch(),
        ),
      ),
    );
  }
}
