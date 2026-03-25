import 'package:flutter/material.dart';
import '../../widgets/gradient_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/system_admin_provider.dart';
import '../../providers/hall_provider.dart';
import '../../widgets/loading_widget.dart';

class CreateHallAdminScreen extends ConsumerStatefulWidget {
  const CreateHallAdminScreen({super.key});

  @override
  ConsumerState<CreateHallAdminScreen> createState() =>
      _CreateHallAdminScreenState();
}

class _CreateHallAdminScreenState extends ConsumerState<CreateHallAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  int? _hallId;
  String _role = 'Admin';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(hallListProvider.notifier).fetch());
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hallsState = ref.watch(hallListProvider);

    return Scaffold(
      appBar: const GradientAppBar(title: 'Add Hall Admin'),
      body: hallsState.when(
        loading: () => const LoadingWidget(),
        error: (_, _) => ErrorRetryWidget(
          message: 'Failed to load halls',
          onRetry: () => ref.read(hallListProvider.notifier).fetch(),
        ),
        data: (halls) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: 'Admin Name',
                    prefixIcon: Icon(Icons.person_rounded),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_rounded),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone_rounded),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: _hallId,
                  decoration: const InputDecoration(
                    labelText: 'Assign to Hall',
                    prefixIcon: Icon(Icons.apartment_rounded),
                  ),
                  items: halls
                      .map(
                        (h) => DropdownMenuItem(
                          value: h.hallId,
                          child: Text(h.hallName),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _hallId = v),
                  validator: (v) => v == null ? 'Select a hall' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _role,
                  decoration: const InputDecoration(
                    labelText: 'Admin Role',
                    prefixIcon: Icon(Icons.shield_rounded),
                  ),
                  items: ['Admin', 'Provost', 'Warden', 'Staff']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _role = v);
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Create Admin'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final data = {
      'adminName': _name.text.trim(),
      'email': _email.text.trim(),
      'phone': _phone.text.trim(),
      'hallId': _hallId,
      'adminRole': _role,
      'status': 'active',
    };

    final result = await ref
        .read(sysAdminHallAdminsProvider.notifier)
        .create(data);
    setState(() => _loading = false);

    if (result != null && mounted) {
      final token = result['registrationToken'] ?? '';
      if (token.toString().isNotEmpty) {
        _showTokenDialog(token.toString());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Admin created successfully')),
        );
        context.pop();
      }
    }
  }

  void _showTokenDialog(String token) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.key_rounded, color: Colors.amber.shade700),
            const SizedBox(width: 8),
            const Text('Registration Token'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share this token with the admin to complete their registration:',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                token,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
