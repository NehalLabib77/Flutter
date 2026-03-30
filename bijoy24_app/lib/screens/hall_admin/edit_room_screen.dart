import 'package:flutter/material.dart';
import '../../widgets/gradient_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/hall_admin_provider.dart';
import '../../widgets/loading_widget.dart';

class EditRoomScreen extends ConsumerStatefulWidget {
  final String roomId;
  const EditRoomScreen({super.key, required this.roomId});

  @override
  ConsumerState<EditRoomScreen> createState() => _EditRoomScreenState();
}

class _EditRoomScreenState extends ConsumerState<EditRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomName = TextEditingController();
  final _capacity = TextEditingController();
  final _wing = TextEditingController();
  final _block = TextEditingController();
  final _floor = TextEditingController();
  String _status = 'Available';
  bool _loading = false;
  bool _initialized = false;

  @override
  void dispose() {
    _roomName.dispose();
    _capacity.dispose();
    _wing.dispose();
    _block.dispose();
    _floor.dispose();
    super.dispose();
  }

  void _initFromRoom() {
    final rooms = ref.read(hallAdminRoomsProvider);
    rooms.whenData((list) {
      final room = list.cast().firstWhere(
        (r) => r.roomId == widget.roomId.toString(),
        orElse: () => null,
      );
      if (room != null && !_initialized) {
        _roomName.text = room.roomName ?? '';
        _capacity.text = '${room.roomCapacity}';
        _wing.text = room.wing ?? '';
        _block.text = room.block ?? '';
        _floor.text = room.floor != null ? '${room.floor}' : '';
        _status = room.status;
        _initialized = true;
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(hallAdminRoomsProvider.notifier).fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hallAdminRoomsProvider);

    state.whenData((_) => _initFromRoom());

    return Scaffold(
      appBar: const GradientAppBar(title: 'Edit Room'),
      body: state.when(
        loading: () => const LoadingWidget(),
        error: (_, _) => ErrorRetryWidget(
          message: 'Failed to load room data',
          onRetry: () => ref.read(hallAdminRoomsProvider.notifier).fetch(),
        ),
        data: (_) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _roomName,
                  decoration: const InputDecoration(
                    labelText: 'Room Name',
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
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.info_outline_rounded),
                  ),
                  items: ['Available', 'Full', 'Maintenance']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
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
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final data = {
      'roomName': _roomName.text.trim(),
      'roomCapacity': int.tryParse(_capacity.text.trim()) ?? 4,
      'wing': _wing.text.trim(),
      'block': _block.text.trim(),
      'floor': int.tryParse(_floor.text.trim()),
      'status': _status,
    };

    final ok = await ref
        .read(hallAdminRoomsProvider.notifier)
        .update(widget.roomId.toString(), data);
    setState(() => _loading = false);

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room updated successfully')),
      );
      context.pop();
    }
  }
}
