import 'package:flutter/material.dart';
import '../../widgets/gradient_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/hall_admin_provider.dart';

class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  ConsumerState<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomNumber = TextEditingController();
  final _roomName = TextEditingController();
  final _capacity = TextEditingController();
  final _wing = TextEditingController();
  final _block = TextEditingController();
  final _floor = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _roomNumber.dispose();
    _roomName.dispose();
    _capacity.dispose();
    _wing.dispose();
    _block.dispose();
    _floor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Create Room'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _roomNumber,
                decoration: const InputDecoration(
                  labelText: 'Room Number',
                  prefixIcon: Icon(Icons.tag_rounded),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roomName,
                decoration: const InputDecoration(
                  labelText: 'Room Name (optional)',
                  prefixIcon: Icon(Icons.meeting_room_rounded),
                ),
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
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _wing,
                      decoration: const InputDecoration(labelText: 'Wing'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _block,
                      decoration: const InputDecoration(labelText: 'Block'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _floor,
                decoration: const InputDecoration(
                  labelText: 'Floor',
                  prefixIcon: Icon(Icons.layers_rounded),
                ),
                keyboardType: TextInputType.number,
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
                      : const Text('Create Room'),
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
      'roomNumber': _roomNumber.text.trim(),
      'roomName': _roomName.text.trim(),
      'roomCapacity': int.tryParse(_capacity.text.trim()) ?? 4,
      'wing': _wing.text.trim(),
      'block': _block.text.trim(),
      'floor': int.tryParse(_floor.text.trim()),
    };

    final ok = await ref.read(hallAdminRoomsProvider.notifier).create(data);
    setState(() => _loading = false);

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room created successfully')),
      );
      context.pop();
    }
  }
}
