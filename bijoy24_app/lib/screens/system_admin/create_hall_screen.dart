import 'package:flutter/material.dart';
import '../../widgets/gradient_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/system_admin_provider.dart';

class CreateHallScreen extends ConsumerStatefulWidget {
  const CreateHallScreen({super.key});

  @override
  ConsumerState<CreateHallScreen> createState() => _CreateHallScreenState();
}

class _CreateHallScreenState extends ConsumerState<CreateHallScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _type = TextEditingController(text: 'Male');
  final _capacity = TextEditingController();
  final _location = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _type.dispose();
    _capacity.dispose();
    _location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Create Hall'),
      body: SingleChildScrollView(
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
                initialValue: 'Male',
                decoration: const InputDecoration(
                  labelText: 'Hall Type',
                  prefixIcon: Icon(Icons.category_rounded),
                ),
                items: ['Male', 'Female', 'Mixed']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => _type.text = v ?? 'Male',
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
                      : const Text('Create Hall'),
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
      'hallName': _name.text.trim(),
      'hallType': _type.text.trim(),
      'hallCapacity': int.tryParse(_capacity.text.trim()) ?? 0,
      'location': _location.text.trim(),
    };

    final ok = await ref.read(sysAdminHallsProvider.notifier).create(data);
    setState(() => _loading = false);

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hall created successfully')),
      );
      context.pop();
    }
  }
}
