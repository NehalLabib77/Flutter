import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../providers/student_provider.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';

class RoommatesScreen extends ConsumerStatefulWidget {
  const RoommatesScreen({super.key});

  @override
  ConsumerState<RoommatesScreen> createState() => _RoommatesScreenState();
}

class _RoommatesScreenState extends ConsumerState<RoommatesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(roommatesProvider.notifier).fetch());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(roommatesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Roommates')),
      body: state.when(
        data: (students) {
          if (students.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.people_outline,
              title: 'No Roommates Found',
              subtitle: 'You have not been assigned to a room yet.',
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(roommatesProvider.notifier).fetch(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: students.length,
              itemBuilder: (context, i) {
                final s = students[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          child: Text(
                            s.studentName.isNotEmpty
                                ? s.studentName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.studentName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'ID: ${s.studentId}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 12,
                                children: [
                                  _infoChip(Icons.phone, s.mobile),
                                  _infoChip(Icons.school, s.faculty),
                                  if (s.bloodGroup != null)
                                    _infoChip(Icons.bloodtype, s.bloodGroup!),
                                ],
                              ),
                            ],
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
        error: (e, _) => ErrorRetryWidget(
          message: 'Failed to load roommates',
          onRetry: () => ref.read(roommatesProvider.notifier).fetch(),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
