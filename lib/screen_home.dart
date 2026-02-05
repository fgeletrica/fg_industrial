import 'core/sb.dart';

import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:pdf/pdf.dart";
import "package:pdf/widgets.dart" as pw;
import "package:printing/printing.dart";

import "supabase_service.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? role;
  String? siteCode;
  String? siteName;

  int todayCount = 0;
  int weekCount = 0;

  @override
  void initState() {
    super.initState();
    _loadHeader();
    _loadCounts();
  }

  Future<void> _loadHeader() async {
    final u = Sb.c.auth.currentUser;
    if (u == null) return;

    final prof = await Sb.c
        .from("profiles")
        .select("role, site_id")
        .eq("user_id", u.id)
        .maybeSingle();

    role = prof?["role"]?.toString();

    final siteId = prof?["site_id"];
    if (siteId != null) {
      final site = await Sb.c
          .from("sites")
          .select("code, name")
          .eq("id", siteId)
          .maybeSingle();
      siteCode = site?["code"]?.toString();
      siteName = site?["name"]?.toString();
    }

    if (mounted) setState(() {});
  }

  Future<void> _loadCounts() async {
    final now = DateTime.now();
    final startToday = DateTime(now.year, now.month, now.day).toIso8601String();
    final startWeek = now.subtract(const Duration(days: 7)).toIso8601String();

    final qToday = await Sb.c
        .from("diagnostics")
        .select("id")
        .gte("created_at", startToday);

    final qWeek = await Sb.c
        .from("diagnostics")
        .select("id")
        .gte("created_at", startWeek);

    todayCount = (qToday as List).length;
    weekCount = (qWeek as List).length;

    if (mounted) setState(() {});
  }

  Future<void> _signOut() async {
    await Sb.c.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final u = Sb.c.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Industrial • ${siteCode ?? "SITE"}"),
        actions: [
          IconButton(
            onPressed: _loadCounts,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blueGrey.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bem-vindo, ${u?.email ?? ""}",
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text("Role: ${role ?? "-"} • Site: ${siteCode ?? "-"}"),
                if (siteName != null) Text(siteName!),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _statCard("Hoje", "$todayCount")),
              const SizedBox(width: 12),
              Expanded(child: _statCard("Últimos 7 dias", "$weekCount")),
            ],
          ),
          const SizedBox(height: 16),
          const Text("Ações", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          _actionCard(
            title: "Novo Diagnóstico",
            subtitle: "Registrar problema + ação tomada + causa raiz.",
            icon: Icons.playlist_add_check,
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NewDiagnosticScreen()),
              );
              _loadCounts();
            },
          ),
          const SizedBox(height: 10),
          _actionCard(
            title: "Histórico + PDF",
            subtitle: "Filtrar e gerar PDF organizado.",
            icon: Icons.picture_as_pdf,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _actionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.18),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(subtitle),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

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

  final problem = TextEditingController();
  final actionTaken = TextEditingController();
  bool rootCause = false;

  String shift = autoShift(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    // pega site do usuário (se tiver)
    final u = Sb.c.auth.currentUser;
    Map<String, dynamic>? prof;
    if (u != null) {
      prof = await Sb.c
          .from("profiles")
          .select("site_id")
          .eq("user_id", u.id)
          .maybeSingle();
    }

    final s = await Sb.c.from("sites").select("id, code, name").order("code");
    sites = (s as List).cast<Map<String, dynamic>>();

    // site padrão: o do perfil, senão o primeiro
    final preferred = prof?["site_id"];
    siteId = preferred?.toString() ?? (sites.isNotEmpty ? sites.first["id"].toString() : null);

    await _loadLines();
    loading = false;
    if (mounted) setState(() {});
  }

  Future<void> _loadLines() async {
    if (siteId == null) return;
    final l = await Sb.c
        .from("lines")
        .select("id, name")
        .eq("site_id", siteId!)
        .order("name");
    lines = (l as List).cast<Map<String, dynamic>>();
    lineId = lines.isNotEmpty ? lines.first["id"].toString() : null;
    await _loadGroups();
  }

  Future<void> _loadGroups() async {
    if (lineId == null) return;
    final g = await Sb.c
        .from("machine_groups")
        .select("id, name")
        .eq("line_id", lineId!)
        .order("name");
    groups = (g as List).cast<Map<String, dynamic>>();
    groupId = groups.isNotEmpty ? groups.first["id"].toString() : null;
    await _loadMachines();
  }

  Future<void> _loadMachines() async {
    if (groupId == null) return;
    final m = await Sb.c
        .from("machines")
        .select("id, name")
        .eq("group_id", groupId!)
        .order("name");
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
    final u = Sb.c.auth.currentUser;
    if (u == null) return;

    if (siteId == null || lineId == null || groupId == null) return;

    await Sb.c.from("diagnostics").insert({
      "site_id": siteId,
      "line_id": lineId,
      "group_id": groupId,
      "machine_id": machineId, // pode ser null se quiser "usar grupo"
      "shift": shift,
      "problem": problem.text.trim(),
      "action_taken": actionTaken.text.trim(),
      "root_cause": rootCause,
      "status": "closed",
      "closed_at": DateTime.now().toIso8601String(),
      "created_by": u.id,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Diagnóstico salvo.")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: Text("Novo Diagnóstico")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Novo Diagnóstico")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Site", style: TextStyle(fontWeight: FontWeight.w700)),
                DropdownButton<String>(
                  value: siteId,
                  isExpanded: true,
                  items: sites
                      .map((e) => DropdownMenuItem(
                            value: e["id"].toString(),
                            child: Text("${e["code"]} • ${e["name"]}"),
                          ))
                      .toList(),
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
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Linha", style: TextStyle(fontWeight: FontWeight.w700)),
                DropdownButton<String>(
                  value: lineId,
                  isExpanded: true,
                  items: lines
                      .map((e) => DropdownMenuItem(
                            value: e["id"].toString(),
                            child: Text(e["name"].toString()),
                          ))
                      .toList(),
                  onChanged: (v) async {
                    setState(() {
                      lineId = v;
                      groups = [];
                      machines = [];
                      groupId = null;
                      machineId = null;
                    });
                    await _loadGroups();
                    setState(() {});
                  },
                ),
                const SizedBox(height: 10),
                const Text("Turno (auto)", style: TextStyle(fontWeight: FontWeight.w700)),
                DropdownButton<String>(
                  value: shift,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: "Manha", child: Text("Manhã")),
                    DropdownMenuItem(value: "Tarde", child: Text("Tarde")),
                    DropdownMenuItem(value: "Noite", child: Text("Noite")),
                    DropdownMenuItem(value: "Indefinido", child: Text("Indefinido")),
                  ],
                  onChanged: (v) => setState(() => shift = v ?? shift),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Máquina (grupo)", style: TextStyle(fontWeight: FontWeight.w700)),
                DropdownButton<String>(
                  value: groupId,
                  isExpanded: true,
                  items: groups
                      .map((e) => DropdownMenuItem(
                            value: e["id"].toString(),
                            child: Text(e["name"].toString()),
                          ))
                      .toList(),
                  onChanged: (v) async {
                    setState(() {
                      groupId = v;
                      machines = [];
                      machineId = null;
                    });
                    await _loadMachines();
                    setState(() {});
                  },
                ),
                const SizedBox(height: 10),
                const Text("Máquina (item)", style: TextStyle(fontWeight: FontWeight.w700)),
                DropdownButton<String>(
                  value: machineId,
                  isExpanded: true,
                  items: machines
                      .map((e) => DropdownMenuItem(
                            value: e["id"].toString(),
                            child: Text(e["name"].toString()),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => machineId = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Problema", style: TextStyle(fontWeight: FontWeight.w700)),
                TextField(
                  controller: problem,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(hintText: "Descreva o problema"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Ação tomada", style: TextStyle(fontWeight: FontWeight.w700)),
                TextField(
                  controller: actionTaken,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(hintText: "O que foi feito para resolver"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _card(
            child: Row(
              children: [
                const Text("Causa raiz", style: TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                Switch(value: rootCause, onChanged: (v) => setState(() => rootCause = v)),
                Text(rootCause ? "SIM" : "NÃO"),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: _save,
            child: const Text("Fechar diagnóstico"),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool loading = true;
  List<Map<String, dynamic>> rows = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await Sb.c
        .from("v_diagnostics_pdf")
        .select()
        .order("created_at", ascending: false)
        .limit(50);

    rows = (data as List).cast<Map<String, dynamic>>();
    loading = false;
    if (mounted) setState(() {});
  }

  Future<void> _makePdf() async {
    final pdf = pw.Document();
    final df = DateFormat("dd/MM/yyyy HH:mm");

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) {
          return [
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.red,
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Coca Cola Andina",
                          style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 2),
                      pw.Text("Relatório - Diagnósticos",
                          style: const pw.TextStyle(color: PdfColors.white)),
                      pw.SizedBox(height: 2),
                      pw.Text("Total de registros: ${rows.length}",
                          style: const pw.TextStyle(color: PdfColors.white)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 12),
            ...rows.map((r) {
              final line = r["line_name"]?.toString() ?? "-";
              final group = r["group_name"]?.toString() ?? "-";
              final machine = r["machine_name"]?.toString() ?? "(usar grupo)";
              final createdAt = DateTime.tryParse(r["created_at"]?.toString() ?? "");
              final dateStr = createdAt == null ? "-" : df.format(createdAt);

              final problem = r["problem"]?.toString() ?? "";
              final action = r["action_taken"]?.toString() ?? "";
              final root = (r["root_cause"] == true) ? "SIM" : "NÃO";

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 10),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text("$line | $group | $machine",
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(dateStr, style: const pw.TextStyle(color: PdfColors.grey700)),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text("Problema", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(problem.isEmpty ? "-" : problem),
                    pw.SizedBox(height: 6),
                    pw.Text("Ação tomada", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(action.isEmpty ? "-" : action),
                    pw.SizedBox(height: 6),
                    pw.Text("Causa raiz: $root"),
                  ],
                ),
              );
            }),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Histórico + PDF"),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: rows.isEmpty ? null : _makePdf, icon: const Icon(Icons.picture_as_pdf)),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: rows.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final r = rows[i];
                final line = r["line_name"]?.toString() ?? "-";
                final group = r["group_name"]?.toString() ?? "-";
                final machine = r["machine_name"]?.toString() ?? "(usar grupo)";
                final createdAt = DateTime.tryParse(r["created_at"]?.toString() ?? "");
                final dateStr = createdAt == null ? "-" : DateFormat("dd/MM HH:mm").format(createdAt);

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("$line | $group | $machine",
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(dateStr),
                      const SizedBox(height: 8),
                      Text("Problema: ${r["problem"] ?? "-"}"),
                      Text("Ação: ${r["action_taken"] ?? "-"}"),
                      Text("Causa raiz: ${(r["root_cause"] == true) ? "SIM" : "NÃO"}"),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: rows.isEmpty ? null : _makePdf,
        label: const Text("Gerar PDF"),
        icon: const Icon(Icons.picture_as_pdf),
      ),
    );
  }
}

/// Retorna o turno automaticamente pelo horário atual.
/// Ajuste as faixas se quiser.
String autoShift(DateTime now) {
  final h = now.hour;
  if (h >= 6 && h < 14) return "Manhã";
  if (h >= 14 && h < 22) return "Tarde";
  return "Noite";
}
