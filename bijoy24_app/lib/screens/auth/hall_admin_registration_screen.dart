import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../constants/app_strings.dart';
import '../../providers/auth_provider.dart';

class HallAdminRegistrationScreen extends ConsumerStatefulWidget {
  const HallAdminRegistrationScreen({super.key});

  @override
  ConsumerState<HallAdminRegistrationScreen> createState() =>
      _HallAdminRegistrationScreenState();
}

class _HallAdminRegistrationScreenState
    extends ConsumerState<HallAdminRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tokenCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _tokenCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final data = {
      'registrationToken': _tokenCtrl.text.trim(),
      'adminName': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'username': _usernameCtrl.text.trim(),
      'password': _passwordCtrl.text,
    };

    final success = await ref
        .read(authProvider.notifier)
        .registerHallAdmin(data);

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
            content: Text('Registration failed. Invalid or used token.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: AppStrings.hallAdminRegistration),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.accentDark),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'You need a registration token from the System Admin to create your account.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _tokenCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Registration Token',
                  prefixIcon: Icon(Icons.vpn_key_outlined),
                  hintText: 'Enter 12-character token',
                ),
                validator: (v) {
                  if (v?.isEmpty == true) return AppStrings.errorRequired;
                  if (v!.length != 12) return 'Token must be 12 characters';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: AppStrings.fullName,
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) =>
                    v?.isEmpty == true ? AppStrings.errorRequired : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (v) =>
                    v?.isEmpty == true ? AppStrings.errorRequired : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _usernameCtrl,
                decoration: const InputDecoration(
                  labelText: AppStrings.username,
                  prefixIcon: Icon(Icons.account_circle_outlined),
                ),
                validator: (v) =>
                    v?.isEmpty == true ? AppStrings.errorRequired : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: AppStrings.password,
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) {
                  if (v?.isEmpty == true) return AppStrings.errorRequired;
                  if (v!.length < 6) return AppStrings.errorPasswordTooShort;
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _confirmPasswordCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: AppStrings.confirmPassword,
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) {
                  if (v?.isEmpty == true) return AppStrings.errorRequired;
                  if (v != _passwordCtrl.text) {
                    return AppStrings.errorPasswordMismatch;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

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
            ],
          ),
        ),
      ),
    );
  }
}
