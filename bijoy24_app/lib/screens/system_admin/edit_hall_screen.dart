import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../providers/system_admin_provider.dart';
import '../../widgets/loading_widget.dart';

class EditHallScreen extends ConsumerStatefulWidget {
  final int hallId;
  const EditHallScreen({super.key, required this.hallId});

  @override
  ConsumerState<EditHallScreen> createState() => _EditHallScreenState();
}

class _EditHallScreenState extends ConsumerState<EditHallScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  String _hallType = 'Male';
  bool _loading = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  void _initFields(dynamic hall) {
    if (_initialized) return;
    _initialized = true;
    _nameCtrl.text = hall.hallName ?? '';
    _locationCtrl.text = hall.location ?? '';
    _hallType = hall.hallType ?? 'Male';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sysAdminHallsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Hall')),
      body: state.when(
        data: (halls) {
          final hall = halls.firstWhere(
            (h) => h.hallId == widget.hallId,
            orElse: () => halls.first,
          );
          _initFields(hall);
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
                      labelText: 'Hall Name *',
                      prefixIcon: Icon(Icons.apartment),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _hallType,
                    decoration: const InputDecoration(
                      labelText: 'Hall Type *',
                      prefixIcon: Icon(Icons.wc),
                    ),
                    items: ['Male', 'Female']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _hallType = v ?? _hallType),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    maxLines: 2,
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
          message: 'Failed to load hall',
          onRetry: () => ref.read(sysAdminHallsProvider.notifier).fetch(),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(sysAdminHallsProvider.notifier).update(widget.hallId, {
        'hallName': _nameCtrl.text.trim(),
        'hallType': _hallType,
        'location': _locationCtrl.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hall updated successfully')),
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
