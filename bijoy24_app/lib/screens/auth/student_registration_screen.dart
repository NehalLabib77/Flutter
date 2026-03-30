import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/hall_provider.dart';

class StudentRegistrationScreen extends ConsumerStatefulWidget {
  const StudentRegistrationScreen({super.key});

  @override
  ConsumerState<StudentRegistrationScreen> createState() =>
      _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState
    extends ConsumerState<StudentRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentIdCtrl = TextEditingController();
  final _boarderNoCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _emergencyNameCtrl = TextEditingController();
  final _emergencyPhoneCtrl = TextEditingController();
  final _fatherCtrl = TextEditingController();
  final _motherCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  String _gender = AppStrings.male;
  String? _bloodGroup;
  String? _faculty;
  String? _religion;
  int _semester = 1;
  int? _selectedHallId;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(hallListProvider.notifier).fetch());
  }

  @override
  void dispose() {
    _studentIdCtrl.dispose();
    _boarderNoCtrl.dispose();
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _emergencyNameCtrl.dispose();
    _emergencyPhoneCtrl.dispose();
    _fatherCtrl.dispose();
    _motherCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedHallId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a hall')));
      return;
    }

    setState(() => _loading = true);

    final data = {
      'studentId': _studentIdCtrl.text.trim(),
      'boarderNo': _boarderNoCtrl.text.trim(),
      'studentName': _nameCtrl.text.trim(),
      'mobile': _mobileCtrl.text.trim(),
      'gender': _gender,
      'bloodGroup': _bloodGroup,
      'faculty': _faculty,
      'semester': _semester,
      'permanentAddress': _addressCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'emergencyContactName': _emergencyNameCtrl.text.trim(),
      'emergencyContactPhone': _emergencyPhoneCtrl.text.trim(),
      'fatherName': _fatherCtrl.text.trim(),
      'motherName': _motherCtrl.text.trim(),
      'religion': _religion,
      'hallId': _selectedHallId,
      'username': _usernameCtrl.text.trim(),
      'password': _passwordCtrl.text,
    };

    final success = await ref.read(authProvider.notifier).registerStudent(data);

    if (mounted) {
      setState(() => _loading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.successRegistration),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration failed. Please check your details.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hallsState = ref.watch(hallListProvider);

    return Scaffold(
      appBar: const GradientAppBar(title: AppStrings.studentRegistration),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SectionHeader('Personal Information'),
              _buildField(_studentIdCtrl, AppStrings.studentId, required: true),
              _buildField(_boarderNoCtrl, AppStrings.boarderNo, required: true),
              _buildField(_nameCtrl, AppStrings.fullName, required: true),
              _buildField(
                _mobileCtrl,
                AppStrings.mobile,
                required: true,
                keyboard: TextInputType.phone,
              ),

              const SizedBox(height: 12),
              const Text(
                'Gender',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Row(
                children: [
                  _radioChoice(AppStrings.male, 'Male'),
                  _radioChoice(AppStrings.female, 'Female'),
                ],
              ),

              DropdownButtonFormField<String>(
                initialValue: _bloodGroup,
                decoration: const InputDecoration(
                  labelText: AppStrings.bloodGroup,
                ),
                items: AppStrings.bloodGroups
                    .map((bg) => DropdownMenuItem(value: bg, child: Text(bg)))
                    .toList(),
                onChanged: (v) => setState(() => _bloodGroup = v),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _faculty,
                decoration: const InputDecoration(
                  labelText: AppStrings.faculty,
                ),
                validator: (v) => v == null ? AppStrings.errorRequired : null,
                items: AppStrings.faculties
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (v) => setState(() => _faculty = v),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<int>(
                initialValue: _semester,
                decoration: const InputDecoration(
                  labelText: AppStrings.semester,
                ),
                items: List.generate(
                  12,
                  (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text('Semester ${i + 1}'),
                  ),
                ),
                onChanged: (v) => setState(() => _semester = v ?? 1),
              ),
              const SizedBox(height: 12),

              _buildField(
                _addressCtrl,
                AppStrings.permanentAddress,
                required: true,
              ),
              _buildField(
                _emailCtrl,
                'Email (optional)',
                keyboard: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),
              const _SectionHeader('Family & Emergency'),
              _buildField(_fatherCtrl, AppStrings.fatherName),
              _buildField(_motherCtrl, AppStrings.motherName),

              DropdownButtonFormField<String>(
                initialValue: _religion,
                decoration: const InputDecoration(
                  labelText: AppStrings.religion,
                ),
                items:
                    ['Islam', 'Hinduism', 'Christianity', 'Buddhism', 'Other']
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                onChanged: (v) => setState(() => _religion = v),
              ),
              const SizedBox(height: 12),

              _buildField(_emergencyNameCtrl, AppStrings.emergencyContactName),
              _buildField(
                _emergencyPhoneCtrl,
                AppStrings.emergencyContactPhone,
                keyboard: TextInputType.phone,
              ),

              const SizedBox(height: 20),
              const _SectionHeader('Hall Selection'),

              hallsState.when(
                data: (halls) {
                  final filtered = halls
                      .where((h) => h.hallType == _gender)
                      .toList();
                  return DropdownButtonFormField<int>(
                    initialValue: _selectedHallId,
                    decoration: const InputDecoration(labelText: 'Select Hall'),
                    validator: (v) => v == null ? 'Please select a hall' : null,
                    items: filtered
                        .map(
                          (h) => DropdownMenuItem(
                            value: h.hallId,
                            child: Text('${h.hallName} (${h.hallType})'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedHallId = v),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text(
                  'Failed to load halls',
                  style: TextStyle(color: AppColors.error),
                ),
              ),

              const SizedBox(height: 20),
              const _SectionHeader('Account Credentials'),
              _buildField(_usernameCtrl, AppStrings.username, required: true),
              _buildPasswordField(_passwordCtrl, AppStrings.password),
              _buildPasswordField(
                _confirmPasswordCtrl,
                AppStrings.confirmPassword,
                matchController: _passwordCtrl,
              ),

              const SizedBox(height: 30),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(AppStrings.register),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label, {
    bool required = false,
    TextInputType? keyboard,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        decoration: InputDecoration(labelText: label),
        validator: required
            ? (v) => v?.isEmpty == true ? AppStrings.errorRequired : null
            : null,
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController ctrl,
    String label, {
    TextEditingController? matchController,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        obscureText: true,
        decoration: InputDecoration(labelText: label),
        validator: (v) {
          if (v?.isEmpty == true) return AppStrings.errorRequired;
          if (v != null && v.length < 6) {
            return AppStrings.errorPasswordTooShort;
          }
          if (matchController != null && v != matchController.text) {
            return AppStrings.errorPasswordMismatch;
          }
          return null;
        },
      ),
    );
  }

  Widget _radioChoice(String value, String label) {
    return Expanded(
      child: RadioListTile<String>(
        title: Text(label, style: const TextStyle(fontSize: 14)),
        value: value,
        groupValue: _gender,
        contentPadding: EdgeInsets.zero,
        onChanged: (v) => setState(() {
          _gender = v!;
          _selectedHallId = null;
        }),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
