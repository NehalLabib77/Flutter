import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../constants/app_strings.dart';
import '../../providers/student_provider.dart';

class SubmitMaintenanceScreen extends ConsumerStatefulWidget {
  const SubmitMaintenanceScreen({super.key});

  @override
  ConsumerState<SubmitMaintenanceScreen> createState() =>
      _SubmitMaintenanceScreenState();
}

class _SubmitMaintenanceScreenState
    extends ConsumerState<SubmitMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _issueCtrl = TextEditingController();
  String _priority = AppStrings.priorityMedium;
  bool _submitting = false;

  @override
  void dispose() {
    _issueCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    final success = await ref.read(studentMaintenanceProvider.notifier).submit({
      'issue': _issueCtrl.text.trim(),
      'priority': _priority,
    });

    if (mounted) {
      setState(() => _submitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.successMaintenanceSubmitted),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to submit request. You need an active room assignment.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Report Maintenance Issue'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Describe the Issue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _issueCtrl,
                maxLines: 5,
                maxLength: 500,
                decoration: const InputDecoration(
                  hintText: 'Describe the maintenance issue in detail...',
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    v?.isEmpty == true ? AppStrings.errorRequired : null,
              ),
              const SizedBox(height: 16),

              const Text(
                'Priority',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    [
                      AppStrings.priorityLow,
                      AppStrings.priorityMedium,
                      AppStrings.priorityHigh,
                      AppStrings.priorityUrgent,
                    ].map((p) {
                      final selected = _priority == p;
                      Color c;
                      switch (p) {
                        case 'Low':
                          c = AppColors.info;
                          break;
                        case 'Medium':
                          c = AppColors.accent;
                          break;
                        case 'High':
                          c = AppColors.warning;
                          break;
                        case 'Urgent':
                          c = AppColors.error;
                          break;
                        default:
                          c = AppColors.textSecondary;
                      }
                      return ChoiceChip(
                        label: Text(p),
                        selected: selected,
                        selectedColor: c.withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: selected ? c : AppColors.textSecondary,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        onSelected: (_) => setState(() => _priority = p),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 32),

              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send),
                  label: const Text('Submit Request'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
