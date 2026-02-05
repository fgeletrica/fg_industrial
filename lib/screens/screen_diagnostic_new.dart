import 'package:flutter/material.dart';
import '../supabase_service.dart';

class NewDiagnosticScreen extends StatefulWidget {
  const NewDiagnosticScreen({super.key});

  @override
  State<NewDiagnosticScreen> createState() => _NewDiagnosticScreenState();
}

class _NewDiagnosticScreenState extends State<NewDiagnosticScreen> {
  bool loading = true;

  List<Map<String, dynamic>> sites = [];
  List<Map<String, dynamic>> lines = [];
  List<Map<String, dynamic>> groups = [];
  List<Map<String, dynamic>> machines = [];

  String? siteId;
  String? lineId;
  String? groupId;
  String? machineId;

  // UI: mostra acento, salva sem acento (pra evitar enum quebrando)
  final shiftUi = const ["Manhã", "Tarde", "Noite", "Indefinido"];
  String shift = "Indefinido";

  final problem = TextEditingController();
  final actionTaken = TextEditingController();
  bool rootCause = false;

  @override
  void initState() {
    super.initState();
    _loadRefs();
  }

  String _shiftToDb(String v) {
    switch (v) {
      case "Manhã":
        return "Manha";
      default:
        return v;
    }
  }

  Future<void> _loadRefs() async {
    setState(() => loading = true);
    try {
      final me = await Sb.c.from("profiles").select("site_id").eq("user_id", Sb.c.auth.currentUser!.id).maybeSingle();
      siteId = me?["site_id"]?.toString();

      final s = await Sb.c.from("sites").select("id, code, name").order("code");
      sites = (s as List).cast<Map<String, dynamic>>();

      if (siteId == null && sites.isNotEmpty) siteId = sites.first["id"].toString();

      await _loadLines();
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _loadLines() async {
    if (siteId == null) return;
    final l = await Sb.c.from("lines").select("id, name").eq("site_id", siteId!).order("name");
    lines = (l as List).cast<Map<String, dynamic>>();
    lineId = lines.isNotEmpty ? lines.first["id"].toString() : null;
    await _loadGroups();
  }

  Future<void> _loadGroups() async {
    if (lineId == null) return;
    final g = await Sb.c.from("machine_groups").select("id, name").eq("line_id", lineId!).order("name");
    groups = (g as List).cast<Map<String, dynamic>>();
    groupId = groups.isNotEmpty ? groups.first["id"].toString() : null;
    await _loadMachines();
  }

  Future<void> _loadMachines() async {
    if (groupId == null) return;
    final m = await Sb.c.from("machines").select("id, name").eq("group_id", groupId!).order("name");
    machines = (m as List).cast<Map<String, dynamic>>();
    machineId = machines.isNotEmpty ? machines.first["id"].toString() : null;
  }

  @override
  void dispose() {
    problem.dispose();
    actionTaken.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (siteId == null || lineId == null || groupId == null) return;
    try {
      final payload = {
        "site_id": siteId,
        "line_id": lineId,
        "group_id": groupId,
        "machine_id": machineId, // pode ser null
        "shift": _shiftToDb(shift),
        "problem": problem.text.trim(),
        "action_taken": actionTaken.text.trim(),
        "root_cause": rootCause,
        "created_by": Sb.c.auth.currentUser!.id,
      };

      await Sb.c.from("diagnostics").insert(payload);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Salvo ✅")));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao salvar: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Novo Diagnóstico")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _drop(
                  label: "Turno",
                  value: shift,
                  items: shiftUi,
                  onChanged: (v) => setState(() => shift = v ?? shift),
                ),
                const SizedBox(height: 10),
                _dropMaps(
                  label: "Site",
                  value: siteId,
                  items: sites,
                  getLabel: (x) => "${x["code"]} — ${x["name"]}",
                  onChanged: (v) async {
                    setState(() {
                      siteId = v;
                      lines = [];
                      groups = [];
                      machines = [];
                      lineId = null;
                      groupId = null;
                      machineId = null;
                    });
                    await _loadLines();
                    if (mounted) setState(() {});
                  },
                ),
                const SizedBox(height: 10),
                _dropMaps(
                  label: "Linha",
                  value: lineId,
                  items: lines,
                  getLabel: (x) => x["name"].toString(),
                  onChanged: (v) async {
                    setState(() {
                      lineId = v;
                      groups = [];
                      machines = [];
                      groupId = null;
                      machineId = null;
                    });
                    await _loadGroups();
                    if (mounted) setState(() {});
                  },
                ),
                const SizedBox(height: 10),
                _dropMaps(
                  label: "Máquinas (grupo)",
                  value: groupId,
                  items: groups,
                  getLabel: (x) => x["name"].toString(),
                  onChanged: (v) async {
                    setState(() {
                      groupId = v;
                      machines = [];
                      machineId = null;
                    });
                    await _loadMachines();
                    if (mounted) setState(() {});
                  },
                ),
                const SizedBox(height: 10),
                _dropMaps(
                  label: "Máquina (item)",
                  value: machineId,
                  items: machines,
                  getLabel: (x) => x["name"].toString(),
                  onChanged: (v) => setState(() => machineId = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: problem,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(labelText: "Problema"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: actionTaken,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(labelText: "Ação tomada"),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text("Causa raiz", style: TextStyle(fontWeight: FontWeight.w800)),
                    const Spacer(),
                    Switch(value: rootCause, onChanged: (v) => setState(() => rootCause = v)),
                    Text(rootCause ? "SIM" : "NÃO"),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save),
                    label: const Text("Salvar"),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _drop({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _dropMaps({
    required String label,
    required String? value,
    required List<Map<String, dynamic>> items,
    required String Function(Map<String, dynamic>) getLabel,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: items
          .map((e) => DropdownMenuItem(value: e["id"].toString(), child: Text(getLabel(e))))
          .toList(),
      onChanged: items.isEmpty ? null : onChanged,
    );
  }
}
