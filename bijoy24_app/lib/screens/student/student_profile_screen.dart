import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/student_provider.dart';
import '../../widgets/loading_widget.dart';

class StudentProfileScreen extends ConsumerStatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  ConsumerState<StudentProfileScreen> createState() =>
      _StudentProfileScreenState();
}

class _StudentProfileScreenState extends ConsumerState<StudentProfileScreen> {
  bool _editing = false;
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _emergencyNameCtrl = TextEditingController();
  final _emergencyPhoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(studentProfileProvider.notifier).fetch());
  }

  @override
  void dispose() {
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _emergencyNameCtrl.dispose();
    _emergencyPhoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final success = await ref.read(studentProfileProvider.notifier).update({
      'mobile': _mobileCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'emergencyContactName': _emergencyNameCtrl.text.trim(),
      'emergencyContactPhone': _emergencyPhoneCtrl.text.trim(),
      'permanentAddress': _addressCtrl.text.trim(),
    });

    if (mounted) {
      setState(() => _editing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? AppStrings.successProfileUpdated
                : 'Failed to update profile',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studentProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _editing = true),
            ),
          if (_editing)
            IconButton(icon: const Icon(Icons.save), onPressed: _saveProfile),
        ],
      ),
      body: state.when(
        data: (student) {
          if (student == null) {
            return const Center(child: Text('Profile not found'));
          }

          if (!_editing) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      student.studentName.isNotEmpty
                          ? student.studentName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    student.studentName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'ID: ${student.studentId}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  _profileSection('Personal Information', [
                    _infoRow('Student ID', student.studentId),
                    _infoRow('Gender', student.gender),
                    _infoRow('Blood Group', student.bloodGroup ?? 'N/A'),
                    _infoRow('Boarder No', student.boarderNo),
                    _infoRow('Status', student.status),
                  ]),
                  _profileSection('Academic Information', [
                    _infoRow('Faculty', student.faculty),
                    _infoRow('Semester', student.semester.toString()),
                  ]),
                  _profileSection('Contact Information', [
                    _infoRow('Mobile', student.mobile),
                    _infoRow('Email', student.email ?? 'N/A'),
                    _infoRow('Address', student.permanentAddress),
                  ]),
                  _profileSection('Family & Emergency', [
                    _infoRow("Father's Name", student.fatherName ?? 'N/A'),
                    _infoRow("Mother's Name", student.motherName ?? 'N/A'),
                    _infoRow('Religion', student.religion ?? 'N/A'),
                    _infoRow(
                      'Emergency Contact',
                      student.emergencyContactName ?? 'N/A',
                    ),
                    _infoRow(
                      'Emergency Phone',
                      student.emergencyContactPhone ?? 'N/A',
                    ),
                  ]),
                ],
              ),
            );
          }

          // Edit mode
          _mobileCtrl.text = student.mobile;
          _emailCtrl.text = student.email ?? '';
          _emergencyNameCtrl.text = student.emergencyContactName ?? '';
          _emergencyPhoneCtrl.text = student.emergencyContactPhone ?? '';
          _addressCtrl.text = student.permanentAddress;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.info, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You can edit your contact information. Student ID, Name, Gender, Faculty and Semester are read-only.',
                          style: TextStyle(fontSize: 12, color: AppColors.info),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _mobileCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Mobile'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _addressCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Permanent Address',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emergencyNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Emergency Contact Name',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emergencyPhoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Emergency Contact Phone',
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _editing = false),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (_, __) => ErrorRetryWidget(
          message: 'Failed to load profile',
          onRetry: () => ref.read(studentProfileProvider.notifier).fetch(),
        ),
      ),
    );
  }

  Widget _profileSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
