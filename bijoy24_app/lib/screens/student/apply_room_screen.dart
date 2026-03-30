import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../constants/app_strings.dart';
import '../../providers/hall_provider.dart';
import '../../providers/student_provider.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/seat_position_selector.dart';

class ApplyRoomScreen extends ConsumerStatefulWidget {
  const ApplyRoomScreen({super.key});

  @override
  ConsumerState<ApplyRoomScreen> createState() => _ApplyRoomScreenState();
}

class _ApplyRoomScreenState extends ConsumerState<ApplyRoomScreen> {
  int? _selectedHallId;
  SeatPosition? _selectedSeatPosition;
  final _reasonController = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(hallListProvider.notifier).fetch());
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedHallId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a hall')));
      return;
    }

    if (_selectedSeatPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a seat preference')),
      );
      return;
    }

    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a reason for your request'),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    final success = await ref.read(roomApplicationProvider.notifier).submit({
      'hallId': _selectedHallId,
      'seatPosition': _selectedSeatPosition!.toApiValue(),
      'reason': _reasonController.text.trim(),
    });

    if (mounted) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? AppStrings.successApplicationSubmitted
                : 'Failed to submit application. You may already have a pending one.',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hallsState = ref.watch(hallListProvider);
    final appState = ref.watch(roomApplicationProvider);

    return Scaffold(
      appBar: const GradientAppBar(title: 'Apply for Room'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            appState.when(
              data: (app) {
                if (app != null) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.getStatusColor(
                        app.status,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.getStatusColor(
                          app.status,
                        ).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Application',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Status: ${app.status}'),
                        Text('Hall: ${app.hallName ?? 'N/A'}'),
                        Text(
                          'Date: ${app.applicationDate.toString().split(' ')[0]}',
                        ),
                        if (app.adminRemarks != null)
                          Text('Remarks: ${app.adminRemarks}'),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const Text(
              'Select a Hall',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose your preferred hall to apply for a room. Only halls matching your gender are shown.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),

            hallsState.when(
              data: (halls) {
                if (halls.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.apartment,
                    title: 'No Halls Available',
                    subtitle: 'There are currently no halls available.',
                  );
                }
                return Column(
                  children: halls.map((hall) {
                    final isSelected = _selectedHallId == hall.hallId;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedHallId = hall.hallId),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.divider,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.apartment,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hall.hallName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    '${hall.hallType} | Capacity: ${hall.hallCapacity}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                  if (hall.location != null)
                                    Text(
                                      hall.location!,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Failed to load halls'),
            ),

            const SizedBox(height: 28),
            const Text(
              'Select Your Seat Preference',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose your preferred seat location in the room',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            SeatPositionSelector(
              selectedPosition: _selectedSeatPosition,
              onSelect: (position) =>
                  setState(() => _selectedSeatPosition = position),
              enabled: _selectedHallId != null,
            ),

            const SizedBox(height: 24),
            const Text(
              'Reason for Request',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tell us why you prefer this seat location',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              minLines: 2,
              enabled: _selectedHallId != null && _selectedSeatPosition != null,
              decoration: InputDecoration(
                hintText:
                    'E.g., Near the window for better ventilation, closer to facilities, etc.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),

            const SizedBox(height: 28),
            SizedBox(
              height: 52,
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
                    : const Text('Submit Application'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
