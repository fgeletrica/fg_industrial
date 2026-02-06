import 'package:flutter/material.dart';
import '../supabase_service.dart';

class UsersManagementScreen extends StatefulWidget {
  UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  bool loading = true;
  String? myRole;
  String? mySiteId;

  List<Map<String, dynamic>> users = [];

  final roles = const ["operator", "technician", "admin", "supervisor"];

  @override
  void initState() {
    super.initState();
    _load();
  }

  bool get canManage => myRole == "supervisor" || myRole == "admin";

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final me = await Sb.c
          .from("profiles")
          .select("role, site_id")
          .eq("user_id", Sb.c.auth.currentUser!.id)
          .maybeSingle();
      myRole = me?["role"]?.toString();
      mySiteId = me?["site_id"]?.toString();

      if (mySiteId == null) {
        users = [];
        if (mounted) setState(() {});
        return;
      }

      var q = Sb.c
          .from("profiles")
          .select("user_id, matricula, full_name, role, site_id, created_at")
          .eq("site_id", mySiteId!);

      final data = await q.order("created_at", ascending: false);
      users = (data as List).cast<Map<String, dynamic>>();

      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro: $e")));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _setRole(String userId, String role) async {
    try {
      await Sb.c.from("profiles").update({"role": role}).eq("user_id", userId);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Cargo atualizado ✅")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro ao atualizar: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Usuários (Gestão)")),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Meu cargo: ${myRole ?? "-"}",
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                          IconButton(
                            onPressed: _load,
                            icon: Icon(Icons.refresh),
                          ),
                        ],
                      ),
                      Divider(),
                      Expanded(
                        child: ListView.separated(
                          itemCount: users.length,
                          separatorBuilder: (_, __) => Divider(height: 18),
                          itemBuilder: (_, i) {
                            final u = users[i];
                            final userId = u["user_id"].toString();
                            final name = (u["full_name"] ?? "").toString();
                            final mat = (u["matricula"] ?? "").toString();
                            final role = (u["role"] ?? "").toString();

                            return Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name.isEmpty ? "(sem nome)" : name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Matrícula: $mat",
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.72),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12),
                                DropdownButton<String>(
                                  value: roles.contains(role)
                                      ? role
                                      : "operator",
                                  items: roles
                                      .map(
                                        (r) => DropdownMenuItem(
                                          value: r,
                                          child: Text(r),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (!canManage)
                                      ? null
                                      : (v) {
                                          if (v == null) return;
                                          _setRole(userId, v);
                                        },
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      if (!canManage)
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            "Somente supervisor/admin pode alterar cargos.",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.72),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
