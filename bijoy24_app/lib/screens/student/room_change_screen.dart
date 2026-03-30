import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../providers/student_provider.dart';
import '../../providers/hall_provider.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';

class RoomChangeScreen extends ConsumerStatefulWidget {
  const RoomChangeScreen({super.key});

  @override
  ConsumerState<RoomChangeScreen> createState() => _RoomChangeScreenState();
}

class _RoomChangeScreenState extends ConsumerState<RoomChangeScreen> {
  final _reasonCtrl = TextEditingController();
  String? _selectedRoomId;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(roomChangeProvider.notifier).fetch();
      ref.read(hallListProvider.notifier).fetch();
    });
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedRoomId == null || _reasonCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a room and provide a reason'),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    final success = await ref.read(roomChangeProvider.notifier).submit({
      'requestedRoomId': _selectedRoomId,
      'reason': _reasonCtrl.text.trim(),
    });

    if (mounted) {
      setState(() => _submitting = false);
      if (success) {
        _reasonCtrl.clear();
        setState(() => _selectedRoomId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Room change request submitted!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to submit. You may already have a pending request.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(roomChangeProvider);

    return Scaffold(
      appBar: const GradientAppBar(title: 'Room Change Request'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'New Request',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _reasonCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Reason for Room Change',
                        hintText:
                            'Describe why you want to change your room...',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        child: _submitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Submit Request'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Request History',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            historyState.when(
              data: (requests) {
                if (requests.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.swap_horiz,
                    title: 'No Room Change Requests',
                    subtitle:
                        'You haven\'t submitted any room change requests yet.',
                  );
                }
                return Column(
                  children: requests.map((r) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
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
                                Expanded(
                                  child: Text(
                                    'Request #${r.requestId}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                StatusBadge(status: r.status),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (r.reason != null)
                              Text(
                                'Reason: ${r.reason}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            Text(
                              'Date: ${r.requestDate.toString().split(' ')[0]}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (r.adminRemarks != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Admin: ${r.adminRemarks}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const LoadingWidget(),
              error: (_, __) => const Text('Failed to load history'),
            ),
          ],
        ),
      ),
    );
  }
}
