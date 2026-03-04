import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../providers/hall_admin_provider.dart';
import '../../widgets/loading_widget.dart';

class EditRoomScreen extends ConsumerStatefulWidget {
  final int roomId;
  const EditRoomScreen({super.key, required this.roomId});

  @override
  ConsumerState<EditRoomScreen> createState() => _EditRoomScreenState();
}

class _EditRoomScreenState extends ConsumerState<EditRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _wingCtrl = TextEditingController();
  final _blockCtrl = TextEditingController();
  final _floorCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  String _status = 'Available';
  bool _loading = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _wingCtrl.dispose();
    _blockCtrl.dispose();
    _floorCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  void _initFields(dynamic room) {
    if (_initialized) return;
    _initialized = true;
    _nameCtrl.text = room.roomName ?? '';
    _wingCtrl.text = room.wing ?? '';
    _blockCtrl.text = room.block ?? '';
    _floorCtrl.text = (room.floor ?? '').toString();
    _capacityCtrl.text = room.roomCapacity.toString();
    _status = room.status ?? 'Available';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hallAdminRoomsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Room')),
      body: state.when(
        data: (rooms) {
          final room = rooms.firstWhere(
            (r) => r.roomId == widget.roomId.toString(),
            orElse: () => rooms.first,
          );
          _initFields(room);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Room ${room.roomNumber}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Room Name'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _wingCtrl,
                          decoration: const InputDecoration(labelText: 'Wing'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _blockCtrl,
                          decoration: const InputDecoration(labelText: 'Block'),
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
                          decoration: const InputDecoration(labelText: 'Floor'),
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
                    onChanged: (v) => setState(() => _status = v ?? _status),
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
          message: 'Failed to load room details',
          onRetry: () => ref.read(hallAdminRoomsProvider.notifier).fetch(),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(hallAdminRoomsProvider.notifier)
          .update(widget.roomId.toString(), {
            'roomName': _nameCtrl.text.trim(),
            'wing': _wingCtrl.text.trim(),
            'block': _blockCtrl.text.trim(),
            'floor': int.tryParse(_floorCtrl.text.trim()),
            'roomCapacity': int.parse(_capacityCtrl.text.trim()),
            'status': _status,
          });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Room updated successfully')));
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
