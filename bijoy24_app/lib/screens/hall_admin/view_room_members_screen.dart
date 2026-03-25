import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../providers/hall_admin_provider.dart';
import '../../widgets/app_card.dart';
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
      appBar: GradientAppBar(title: 'Room #${widget.roomId} Members'),
      body: state.when(
        data: (all) {
          final members = all
              .where((a) => a.roomIdentity.contains(widget.roomId.toString()))
              .toList();
          if (members.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.people_outline_rounded,
              title: 'No Members',
              subtitle: 'This room has no assigned students',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: members.length,
            itemBuilder: (ctx, i) {
              final m = members[i];
              return AppCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primarySurface,
                      child: Text(
                        (m.studentName ?? 'S').substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.studentName ?? 'Student',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${m.faculty ?? 'N/A'} • Since ${m.assignmentDate.toString().split(' ').first}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (m.mobile != null)
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.phone_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const LoadingWidget(),
        error: (_, _) => ErrorRetryWidget(
          message: 'Failed to load room members',
          onRetry: () =>
              ref.read(hallAdminAssignmentsProvider.notifier).fetch(),
        ),
      ),
    );
  }
}
