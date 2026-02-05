import 'package:flutter/material.dart';
import 'core/sb.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  bool loading = true;
  String? err;

  List<Map<String, dynamic>> rows = [];
  final Map<String, String> pendingRole = {}; // user_id -> role

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      err = null;
    });

    try {
      final data = await Sb.c
          .from('v_users_management')
          .select()
          .order('full_name', ascending: true);

      rows = (data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      err = e.toString();
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _saveRole(String userId, String role) async {
    try {
      await Sb.c
          .from('profiles')
          .update({'role': role})
          .eq('user_id', userId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cargo atualizado.')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuários (Gestão)'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : err != null
              ? Center(child: Text(err!))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final r = rows[i];
                    final userId = (r['user_id'] ?? '').toString();
                    final name = (r['full_name'] ?? '-').toString();
                    final mat = (r['matricula'] ?? '-').toString();
                    final siteId = (r['site_id'] ?? '-').toString();
                    final currentRole = (r['role'] ?? '-').toString();

                    final selected = pendingRole[userId] ?? currentRole;

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text('Matrícula: $mat • Site: $siteId',
                                style: const TextStyle(color: Colors.white70)),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: selected,
                                    decoration: const InputDecoration(labelText: 'Cargo'),
                                    items: const [
                                      DropdownMenuItem(value: 'operator', child: Text('operator')),
                                      DropdownMenuItem(value: 'staff', child: Text('staff')),
                                      DropdownMenuItem(value: 'management', child: Text('management')),
                                      DropdownMenuItem(value: 'admin', child: Text('admin')),
                                      DropdownMenuItem(value: 'owner', child: Text('owner')),
                                    ],
                                    onChanged: (v) {
                                      if (v == null) return;
                                      setState(() => pendingRole[userId] = v);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: userId.isEmpty ? null : () => _saveRole(userId, selected),
                                  child: const Text('Salvar'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
