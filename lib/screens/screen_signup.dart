import 'package:flutter/material.dart';
import '../supabase_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final email = TextEditingController();
  final pass = TextEditingController();
  final matricula = TextEditingController();
  final fullName = TextEditingController();
  final siteCode = TextEditingController(text: "DQX"); // default
  bool loading = false;

  Future<void> _signup() async {
    setState(() => loading = true);
    try {
      await Sb.c.auth.signUp(
        email: email.text.trim(),
        password: pass.text,
        data: {
          // usado pelo trigger handle_new_user (SQL)
          "matricula": matricula.text.trim(),
          "full_name": fullName.text.trim(),
          "site_code": siteCode.text.trim(),
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Conta criada. Se precisar confirmar email, confira sua caixa.")),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    matricula.dispose();
    fullName.dispose();
    siteCode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Criar conta")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: email, decoration: const InputDecoration(labelText: "Email")),
                    const SizedBox(height: 10),
                    TextField(controller: pass, obscureText: true, decoration: const InputDecoration(labelText: "Senha")),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: matricula, decoration: const InputDecoration(labelText: "Matrícula"))),
                        const SizedBox(width: 10),
                        Expanded(child: TextField(controller: siteCode, decoration: const InputDecoration(labelText: "Site (code)"))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(controller: fullName, decoration: const InputDecoration(labelText: "Nome completo")),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: loading ? null : _signup,
                        child: Text(loading ? "Criando..." : "Criar conta"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
