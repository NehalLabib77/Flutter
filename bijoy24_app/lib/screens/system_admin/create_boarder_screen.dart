import 'package:flutter/material.dart';
import '../../widgets/gradient_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/system_admin_provider.dart';
import '../../providers/hall_provider.dart';
import '../../widgets/loading_widget.dart';

class CreateBoarderScreen extends ConsumerStatefulWidget {
  const CreateBoarderScreen({super.key});

  @override
  ConsumerState<CreateBoarderScreen> createState() =>
      _CreateBoarderScreenState();
}

class _CreateBoarderScreenState extends ConsumerState<CreateBoarderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _boarderNo = TextEditingController();
  final _studentName = TextEditingController();
  final _studentId = TextEditingController();
  final _department = TextEditingController();
  final _session = TextEditingController();
  int? _hallId;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(hallListProvider.notifier).fetch());
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

  @override
  Widget build(BuildContext context) {
    final hallsState = ref.watch(hallListProvider);

    return Scaffold(
      appBar: const GradientAppBar(title: 'Add Boarder'),
      body: hallsState.when(
        loading: () => const LoadingWidget(),
        error: (_, _) => ErrorRetryWidget(
          message: 'Failed to load halls',
          onRetry: () => ref.read(hallListProvider.notifier).fetch(),
        ),
        data: (halls) => SingleChildScrollView(
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
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
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
                    labelText: 'Session (e.g. 2024-2025)',
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
                  items: halls
                      .map(
                        (h) => DropdownMenuItem(
                          value: h.hallId,
                          child: Text(h.hallName),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _hallId = v),
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
                        : const Text('Add Boarder'),
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
      'boarderNo': _boarderNo.text.trim(),
      'studentName': _studentName.text.trim(),
      'studentId': _studentId.text.trim(),
      'department': _department.text.trim(),
      'session': _session.text.trim(),
      'hallId': _hallId,
      'status': 'active',
    };

    final ok = await ref.read(boarderRegistryProvider.notifier).create(data);
    setState(() => _loading = false);

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Boarder added successfully')),
      );
      context.pop();
    }
  }
}
