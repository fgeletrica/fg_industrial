import 'core/sb.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';

class HistoryPdfCsvScreen extends StatefulWidget {
  const HistoryPdfCsvScreen({super.key});
  @override
  State<HistoryPdfCsvScreen> createState() => _HistoryPdfCsvScreenState();
}

class _HistoryPdfCsvScreenState extends State<HistoryPdfCsvScreen> {
  bool booting = true;
  bool searching = false;

  DateTime from = DateTime.now();
  DateTime to = DateTime.now();

  String shift = "ALL";
  String? lineId;
  String? groupId;
  String? machineId;

  List<Map<String, dynamic>> lines = [];
  List<Map<String, dynamic>> groups = [];
  List<Map<String, dynamic>> machines = [];

  List<Map<String, dynamic>> results = [];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  String _fmt(DateTime d) => DateFormat("dd/MM/yyyy").format(d);
  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day, 0, 0, 0);
  DateTime _endOfDay(DateTime d) => DateTime(d.year, d.month, d.day, 23, 59, 59);

  Future<void> _bootstrap() async {
    setState(() => booting = true);

    try {
      final u = Sb.c.auth.currentUser;
      if (u == null) throw Exception("Usuário não logado.");

      // pega site do usuário
      final prof = await Sb.c
          .from("v_users_management")
          .select("site_id, role")
          .eq("user_id", u.id)
          .maybeSingle();
final siteId = prof?["site_id"]?.toString();
      if (siteId == null || siteId.isEmpty) {
        throw Exception("Seu usuário está sem site_id no profiles.");
      }

      // carrega linhas do site
      final l = await Sb.c
          .from("lines")
          .select("id, name")
          .eq("site_id", siteId)
          .order("name");
      lines = (l as List).cast<Map<String, dynamic>>();

      // padrão: nada selecionado (ALL)
      lineId = null;
      groupId = null;
      machineId = null;

      groups = [];
      machines = [];

      results = [];
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao carregar filtros: $e")),
        );
      }
    } finally {
      booting = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _loadGroups() async {
    if (lineId == null) {
      groups = [];
      groupId = null;
      machines = [];
      machineId = null;
      return;
    }
    final g = await Sb.c
        .from("machine_groups")
        .select("id, name")
        .eq("line_id", lineId!)
        .order("name");
    groups = (g as List).cast<Map<String, dynamic>>();
    groupId = null;
    machines = [];
    machineId = null;
  }

  Future<void> _loadMachines() async {
    if (groupId == null) {
      machines = [];
      machineId = null;
      return;
    }
    final m = await Sb.c
        .from("machines")
        .select("id, name")
        .eq("group_id", groupId!)
        .order("name");
    machines = (m as List).cast<Map<String, dynamic>>();
    machineId = null;
  }

  Future<void> _pickFrom() async {
    final d = await showDatePicker(
      context: context,
      initialDate: from,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => from = d);
  }

  Future<void> _pickTo() async {
    final d = await showDatePicker(
      context: context,
      initialDate: to,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => to = d);
  }

  Future<void> _search() async {
    setState(() => searching = true);

    try {
      final u = Sb.c.auth.currentUser;
      if (u == null) throw Exception("Usuário não logado.");

      final prof = await Sb.c
          .from("v_users_management")
          .select("site_id, role")
          .eq("user_id", u.id)
          .maybeSingle();
final siteId = prof?["site_id"]?.toString();
      if (siteId == null || siteId.isEmpty) {
        throw Exception("Seu usuário está sem site_id no profiles.");
      }

      // ✅ dynamic evita o Dart travar o tipo e “sumir” com eq()
      dynamic q = Sb.c
          .from("diagnostics")
          .select("id, created_at, shift, problem, action_taken, root_cause, status, line_id, group_id, machine_id")
          .eq("site_id", siteId)
          .gte("created_at", _startOfDay(from).toIso8601String())
          .lte("created_at", _endOfDay(to).toIso8601String());

      if (shift != "ALL") q = q.eq("shift", shift);
      if (lineId != null) q = q.eq("line_id", lineId!);
      if (groupId != null) q = q.eq("group_id", groupId!);
      if (machineId != null) q = q.eq("machine_id", machineId!);

      final data = await q.order("created_at", ascending: false);
      results = (data as List).cast<Map<String, dynamic>>();

      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao buscar: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => searching = false);
    }
  }

  Future<void> _genPdf() async {
    if (results.isEmpty) return;

    final df = DateFormat("dd/MM/yyyy HH:mm");
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => [
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
                    pw.Text(
                      "Coca-Cola Andina",
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text("Relatório - Diagnósticos",
                        style: const pw.TextStyle(color: PdfColors.white)),
                    pw.SizedBox(height: 2),
                    pw.Text("Período: ${_fmt(from)} até ${_fmt(to)} • Turno: $shift",
                        style: const pw.TextStyle(color: PdfColors.white)),
                    pw.SizedBox(height: 2),
                    pw.Text("Total: ${results.length}",
                        style: const pw.TextStyle(color: PdfColors.white)),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 12),
          ...results.map((r) {
            final createdAt = DateTime.tryParse(r["created_at"]?.toString() ?? "");
            final dateStr = createdAt == null ? "-" : df.format(createdAt);

            final problem = (r["problem"] ?? "").toString();
            final action = (r["action_taken"] ?? "").toString();
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
                      pw.Text("Turno: ${r["shift"] ?? "-"}",
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
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  Future<void> _genCsvToClipboard() async {
    if (results.isEmpty) return;

    final sb = StringBuffer();
    sb.writeln("created_at,shift,problem,action_taken,root_cause,status,line_id,group_id,machine_id");
    for (final r in results) {
      String esc(String s) => '"${s.replaceAll('"', '""')}"';
      sb.writeln([
        esc((r["created_at"] ?? "").toString()),
        esc((r["shift"] ?? "").toString()),
        esc((r["problem"] ?? "").toString()),
        esc((r["action_taken"] ?? "").toString()),
        esc((r["root_cause"] ?? "").toString()),
        esc((r["status"] ?? "").toString()),
        esc((r["line_id"] ?? "").toString()),
        esc((r["group_id"] ?? "").toString()),
        esc((r["machine_id"] ?? "").toString()),
      ].join(","));
    }

    await Clipboard.setData(ClipboardData(text: sb.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("CSV copiado para a área de transferência.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canExport = results.isNotEmpty && !searching && !booting;
    final gold = Theme.of(context).colorScheme.primary;

    if (booting) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Histórico • PDF/CSV"),
        actions: [
          IconButton(onPressed: _bootstrap, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _dateRow("De", _fmt(from), _pickFrom)),
                      const SizedBox(width: 12),
                      Expanded(child: _dateRow("Até", _fmt(to), _pickTo)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Turno", style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: shift,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: "ALL", child: Text("ALL")),
                      DropdownMenuItem(value: "Manha", child: Text("Manhã")),
                      DropdownMenuItem(value: "Tarde", child: Text("Tarde")),
                      DropdownMenuItem(value: "Noite", child: Text("Noite")),
                      DropdownMenuItem(value: "Indefinido", child: Text("Indefinido")),
                    ],
                    onChanged: (v) => setState(() => shift = v ?? "ALL"),
                  ),
                  const SizedBox(height: 12),

                  const Text("Linha", style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    value: lineId,
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(value: null, child: Text("ALL")),
                      ...lines.map((e) => DropdownMenuItem(
                            value: e["id"].toString(),
                            child: Text(e["name"].toString()),
                          )),
                    ],
                    onChanged: (v) async {
                      setState(() {
                        lineId = v;
                        groupId = null;
                        machineId = null;
                        groups = [];
                        machines = [];
                      });
                      await _loadGroups();
                      if (mounted) setState(() {});
                    },
                  ),
                  const SizedBox(height: 12),

                  const Text("Máquinas (grupo)", style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    value: groupId,
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(value: null, child: Text("ALL")),
                      ...groups.map((e) => DropdownMenuItem(
                            value: e["id"].toString(),
                            child: Text(e["name"].toString()),
                          )),
                    ],
                    onChanged: (v) async {
                      setState(() {
                        groupId = v;
                        machineId = null;
                        machines = [];
                      });
                      await _loadMachines();
                      if (mounted) setState(() {});
                    },
                  ),
                  const SizedBox(height: 12),

                  const Text("Máquina (item)", style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    value: machineId,
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(value: null, child: Text("ALL")),
                      ...machines.map((e) => DropdownMenuItem(
                            value: e["id"].toString(),
                            child: Text(e["name"].toString()),
                          )),
                    ],
                    onChanged: (v) => setState(() => machineId = v),
                  ),

                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: searching ? null : _search,
                    icon: const Icon(Icons.search),
                    label: Text(searching ? "Buscando..." : "Buscar"),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Icon(Icons.check_box, size: 18, color: Colors.white60),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "O histórico só aparece depois do Buscar.",
                          style: TextStyle(color: Colors.white60),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Resultados: ${results.length}",
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: canExport ? _genPdf : null,
                          child: const Text("Gerar PDF"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: canExport ? _genCsvToClipboard : null,
                          child: const Text("Gerar CSV"),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  if (results.isEmpty)
                    const Text("Selecione os filtros e clique em Buscar.",
                        style: TextStyle(color: Colors.white60)),
                  if (results.isNotEmpty)
                    Container(
                      height: 2,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: gold.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateRow(String label, String value, VoidCallback onTap) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: OutlinedButton(
            onPressed: onTap,
            child: Text(value),
          ),
        ),
      ],
    );
  }
}
