import 'package:flutter/material.dart';
import '../../widgets/gradient_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  int? _hallId;
  String _role = 'Admin';
  String _status = 'active';
  bool _loading = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(sysAdminHallAdminsProvider.notifier).fetch();
      ref.read(hallListProvider.notifier).fetch();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _initAdmin() {
    final state = ref.read(sysAdminHallAdminsProvider);
    state.whenData((list) {
      final admin = list.cast().firstWhere(
        (a) => a.hallAdminId == widget.adminId,
        orElse: () => null,
      );
      if (admin != null && !_initialized) {
        _name.text = admin.adminName;
        _email.text = admin.email ?? '';
        _phone.text = admin.phone ?? '';
        _hallId = admin.hallId;
        _role = admin.adminRole;
        _status = admin.status;
        _initialized = true;
        if (mounted) setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminsState = ref.watch(sysAdminHallAdminsProvider);
    final hallsState = ref.watch(hallListProvider);
    adminsState.whenData((_) => _initAdmin());

    final isReady = adminsState is AsyncData && hallsState is AsyncData;

    return Scaffold(
      appBar: const GradientAppBar(title: 'Edit Admin'),
      body: !isReady
          ? adminsState is AsyncError || hallsState is AsyncError
                ? ErrorRetryWidget(
                    message: 'Failed to load data',
                    onRetry: () {
                      ref.read(sysAdminHallAdminsProvider.notifier).fetch();
                      ref.read(hallListProvider.notifier).fetch();
                    },
                  )
                : const LoadingWidget()
          : SingleChildScrollView(
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
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
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
                      items: (hallsState.value ?? [])
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
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _role = v);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.toggle_on_rounded),
                      ),
                      items: ['active', 'inactive', 'suspended']
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(s[0].toUpperCase() + s.substring(1)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _status = v);
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
                            : const Text('Save Changes'),
                      ),
                    ),
                  ],
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
      'status': _status,
    };

    final ok = await ref
        .read(sysAdminHallAdminsProvider.notifier)
        .update(widget.adminId, data);
    setState(() => _loading = false);

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin updated successfully')),
      );
      context.pop();
    }
  }
}
