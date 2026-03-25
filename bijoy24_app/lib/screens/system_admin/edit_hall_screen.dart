import 'package:flutter/material.dart';
import '../../widgets/gradient_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  final _name = TextEditingController();
  String _type = 'Male';
  final _capacity = TextEditingController();
  final _location = TextEditingController();
  bool _loading = false;
  bool _initialized = false;

  @override
  void dispose() {
    _name.dispose();
    _capacity.dispose();
    _location.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(sysAdminHallsProvider.notifier).fetch());
  }

  void _initFromHall() {
    final halls = ref.read(sysAdminHallsProvider);
    halls.whenData((list) {
      final hall = list.cast().firstWhere(
        (h) => h.hallId == widget.hallId,
        orElse: () => null,
      );
      if (hall != null && !_initialized) {
        _name.text = hall.hallName;
        _type = hall.hallType;
        _capacity.text = '${hall.hallCapacity}';
        _location.text = hall.location ?? '';
        _initialized = true;
        if (mounted) setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sysAdminHallsProvider);
    state.whenData((_) => _initFromHall());

    return Scaffold(
      appBar: const GradientAppBar(title: 'Edit Hall'),
      body: state.when(
        loading: () => const LoadingWidget(),
        error: (_, _) => ErrorRetryWidget(
          message: 'Failed to load hall',
          onRetry: () => ref.read(sysAdminHallsProvider.notifier).fetch(),
        ),
        data: (_) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: 'Hall Name',
                    prefixIcon: Icon(Icons.apartment_rounded),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  decoration: const InputDecoration(
                    labelText: 'Hall Type',
                    prefixIcon: Icon(Icons.category_rounded),
                  ),
                  items: ['Male', 'Female', 'Mixed']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _type = v);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _capacity,
                  decoration: const InputDecoration(
                    labelText: 'Capacity',
                    prefixIcon: Icon(Icons.people_rounded),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _location,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    prefixIcon: Icon(Icons.location_on_rounded),
                  ),
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
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final data = {
      'hallName': _name.text.trim(),
      'hallType': _type,
      'hallCapacity': int.tryParse(_capacity.text.trim()) ?? 0,
      'location': _location.text.trim(),
    };

    final ok = await ref
        .read(sysAdminHallsProvider.notifier)
        .update(widget.hallId, data);
    setState(() => _loading = false);

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hall updated successfully')),
      );
      context.pop();
    }
  }
}
