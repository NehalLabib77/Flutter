import 'package:flutter/material.dart';
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
  final _roomNumberCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _wingCtrl = TextEditingController();
  final _blockCtrl = TextEditingController();
  final _floorCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController(text: '4');
  String _status = 'Available';
  bool _loading = false;

  @override
  void dispose() {
    _roomNumberCtrl.dispose();
    _nameCtrl.dispose();
    _wingCtrl.dispose();
    _blockCtrl.dispose();
    _floorCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Room')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _roomNumberCtrl,
                decoration: const InputDecoration(
                  labelText: 'Room Number *',
                  hintText: 'e.g. 301',
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Room Name',
                  hintText: 'e.g. Room 301-A',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _wingCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Wing',
                        hintText: 'e.g. North',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _blockCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Block',
                        hintText: 'e.g. A',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _floorCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Floor',
                        hintText: 'e.g. 3',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _capacityCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Capacity *',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final n = int.tryParse(v);
                        if (n == null || n < 1 || n > 8) {
                          return '1-8 seats';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: ['Available', 'Full', 'Maintenance']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _status = v ?? 'Available'),
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
                    : const Text('Create Room'),
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
    try {
      await ref.read(hallAdminRoomsProvider.notifier).create({
        'roomNumber': _roomNumberCtrl.text.trim(),
        'roomName': _nameCtrl.text.trim(),
        'wing': _wingCtrl.text.trim(),
        'block': _blockCtrl.text.trim(),
        'floor': int.tryParse(_floorCtrl.text.trim()),
        'roomCapacity': int.parse(_capacityCtrl.text.trim()),
        'status': _status,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room created successfully')),
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
