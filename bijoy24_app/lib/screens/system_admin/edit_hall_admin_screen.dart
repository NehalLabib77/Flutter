import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../providers/system_admin_provider.dart';
import '../../providers/hall_provider.dart';
import '../../widgets/loading_widget.dart';

class EditHallAdminScreen extends ConsumerStatefulWidget {
  final int adminId;
  const EditHallAdminScreen({super.key, required this.adminId});

  @override
  ConsumerState<EditHallAdminScreen> createState() =>
      _EditHallAdminScreenState();
}

class _EditHallAdminScreenState extends ConsumerState<EditHallAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  int? _selectedHallId;
  bool _loading = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(hallListProvider.notifier).fetch());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _initFields(dynamic admin) {
    if (_initialized) return;
    _initialized = true;
    _nameCtrl.text = admin.adminName ?? '';
    _emailCtrl.text = admin.email ?? '';
    _phoneCtrl.text = admin.phone ?? '';
    _selectedHallId = admin.hallId;
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(sysAdminHallAdminsProvider);
    final hallsState = ref.watch(hallListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Hall Admin')),
      body: adminState.when(
        data: (admins) {
          final admin = admins.firstWhere(
            (a) => a.hallAdminId == widget.adminId,
            orElse: () => admins.first,
          );
          _initFields(admin);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Email *',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (!v.contains('@')) return 'Invalid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  hallsState.when(
                    data: (halls) => DropdownButtonFormField<int>(
                      value: _selectedHallId,
                      decoration: const InputDecoration(
                        labelText: 'Assign to Hall *',
                        prefixIcon: Icon(Icons.apartment),
                      ),
                      items: halls
                          .map(
                            (h) => DropdownMenuItem(
                              value: h.hallId,
                              child: Text(h.hallName ?? 'Hall #${h.hallId}'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedHallId = v),
                      validator: (v) => v == null ? 'Select a hall' : null,
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Failed to load halls'),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (_, __) => ErrorRetryWidget(
          message: 'Failed to load admin',
          onRetry: () => ref.read(sysAdminHallAdminsProvider.notifier).fetch(),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(sysAdminHallAdminsProvider.notifier)
          .update(widget.adminId, {
            'name': _nameCtrl.text.trim(),
            'email': _emailCtrl.text.trim(),
            'phone': _phoneCtrl.text.trim(),
            'hallId': _selectedHallId,
          });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hall admin updated successfully')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
