import 'package:flutter/material.dart';
import '../../widgets/gradient_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  final _boarderNo = TextEditingController();
  final _studentName = TextEditingController();
  final _studentId = TextEditingController();
  final _department = TextEditingController();
  final _session = TextEditingController();
  int? _hallId;
  String _status = 'active';
  bool _loading = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(boarderRegistryProvider.notifier).fetch();
      ref.read(hallListProvider.notifier).fetch();
    });
  }

  @override
  void dispose() {
    _boarderNo.dispose();
    _studentName.dispose();
    _studentId.dispose();
    _department.dispose();
    _session.dispose();
    super.dispose();
  }

  void _initData() {
    final state = ref.read(boarderRegistryProvider);
    state.whenData((list) {
      final b = list.cast().firstWhere(
        (b) => b.registryId == widget.boarderId,
        orElse: () => null,
      );
      if (b != null && !_initialized) {
        _boarderNo.text = b.boarderNo;
        _studentName.text = b.studentName ?? '';
        _studentId.text = b.studentId ?? '';
        _department.text = b.department ?? '';
        _session.text = b.session ?? '';
        _hallId = b.hallId;
        _status = b.status;
        _initialized = true;
        if (mounted) setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final boarderState = ref.watch(boarderRegistryProvider);
    final hallsState = ref.watch(hallListProvider);
    boarderState.whenData((_) => _initData());

    final isReady = boarderState is AsyncData && hallsState is AsyncData;

    return Scaffold(
      appBar: const GradientAppBar(title: 'Edit Boarder'),
      body: !isReady
          ? boarderState is AsyncError || hallsState is AsyncError
                ? ErrorRetryWidget(
                    message: 'Failed to load data',
                    onRetry: () {
                      ref.read(boarderRegistryProvider.notifier).fetch();
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
                      controller: _boarderNo,
                      decoration: const InputDecoration(
                        labelText: 'Boarder No',
                        prefixIcon: Icon(Icons.tag_rounded),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _studentName,
                      decoration: const InputDecoration(
                        labelText: 'Student Name',
                        prefixIcon: Icon(Icons.person_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _studentId,
                      decoration: const InputDecoration(
                        labelText: 'Student ID',
                        prefixIcon: Icon(Icons.badge_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _department,
                      decoration: const InputDecoration(
                        labelText: 'Department',
                        prefixIcon: Icon(Icons.school_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _session,
                      decoration: const InputDecoration(
                        labelText: 'Session',
                        prefixIcon: Icon(Icons.calendar_month_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: _hallId,
                      decoration: const InputDecoration(
                        labelText: 'Hall',
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
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.toggle_on_rounded),
                      ),
                      items: ['active', 'inactive', 'graduated', 'expelled']
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
      'boarderNo': _boarderNo.text.trim(),
      'studentName': _studentName.text.trim(),
      'studentId': _studentId.text.trim(),
      'department': _department.text.trim(),
      'session': _session.text.trim(),
      'hallId': _hallId,
      'status': _status,
    };

    final ok = await ref
        .read(boarderRegistryProvider.notifier)
        .update(widget.boarderId, data);
    setState(() => _loading = false);

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Boarder updated successfully')),
      );
      context.pop();
    }
  }
}
