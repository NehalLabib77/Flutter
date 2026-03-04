import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../providers/system_admin_provider.dart';
import '../../providers/hall_provider.dart';
import '../../widgets/loading_widget.dart';

class EditBoarderScreen extends ConsumerStatefulWidget {
  final int boarderId;
  const EditBoarderScreen({super.key, required this.boarderId});

  @override
  ConsumerState<EditBoarderScreen> createState() => _EditBoarderScreenState();
}

class _EditBoarderScreenState extends ConsumerState<EditBoarderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _studentIdCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  final _sessionCtrl = TextEditingController();
  int? _selectedHallId;
  String _status = 'Active';
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
    _studentIdCtrl.dispose();
    _deptCtrl.dispose();
    _sessionCtrl.dispose();
    super.dispose();
  }

  void _initFields(dynamic b) {
    if (_initialized) return;
    _initialized = true;
    _nameCtrl.text = b.studentName ?? '';
    _studentIdCtrl.text = (b.studentId ?? '').toString();
    _deptCtrl.text = b.department ?? '';
    _sessionCtrl.text = b.session ?? '';
    _selectedHallId = b.hallId;
    _status = b.status ?? 'Active';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(boarderRegistryProvider);
    final hallsState = ref.watch(hallListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Boarder')),
      body: state.when(
        data: (boarders) {
          final b = boarders.firstWhere(
            (x) => x.registryId == widget.boarderId,
            orElse: () => boarders.first,
          );
          _initFields(b);
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
                      labelText: 'Student Name *',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _studentIdCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Student ID *',
                      prefixIcon: Icon(Icons.badge),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _deptCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      prefixIcon: Icon(Icons.school),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _sessionCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Session',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
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
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      prefixIcon: Icon(Icons.toggle_on),
                    ),
                    items: ['Active', 'Inactive', 'Graduated']
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
          message: 'Failed to load boarder',
          onRetry: () => ref.read(boarderRegistryProvider.notifier).fetch(),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(boarderRegistryProvider.notifier)
          .update(widget.boarderId, {
            'studentName': _nameCtrl.text.trim(),
            'studentId': _studentIdCtrl.text.trim(),
            'department': _deptCtrl.text.trim(),
            'session': _sessionCtrl.text.trim(),
            'hallId': _selectedHallId,
            'status': _status,
          });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Boarder updated successfully')),
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
