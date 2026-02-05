import 'core/sb.dart';

import "package:flutter/material.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "supabase_service.dart";
import "app_config.dart";
import "screen_home.dart";

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();
  final _city = TextEditingController();
  final _wa = TextEditingController();
  final _mat = TextEditingController();
  final _pass = TextEditingController();

  bool _loading = false;
  String? _err;

  bool get _ok =>
      _mat.text.trim().length >= 3 &&
      _pass.text.trim().length >= 6 &&
      _name.text.trim().isNotEmpty;

  Future<void> _signup() async {
    if (!_ok) {
      setState(() => _err = "Preencha Nome, Matrícula e Senha (6+).");
      return;
    }

    setState(() { _loading = true; _err = null; });

    try {
      final matricula = _mat.text.trim();
      final email = Sb.emailFromMatricula(matricula);
      final pass = _pass.text.trim();

      await Sb.c.auth.signUp(
        email: email,
        password: pass,
        data: {
          "matricula": matricula,
          "site_code": AppConfig.defaultSiteCode,
          "full_name": _name.text.trim(),
          "city": _city.text.trim(),
          "whatsapp": _wa.text.trim(),
        },
      );

      // entra direto (se Confirm Email estiver OFF)
      await Sb.c.auth.signInWithPassword(email: email, password: pass);

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } on AuthException catch (e) {
      setState(() => _err = e.message);
    } catch (e) {
      setState(() => _err = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _name.dispose(); _city.dispose(); _wa.dispose(); _mat.dispose(); _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Criar conta (Industrial)")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(controller: _name, decoration: const InputDecoration(labelText: "Nome")),
                const SizedBox(height: 10),
                TextField(controller: _city, decoration: const InputDecoration(labelText: "Cidade/Bairro")),
                const SizedBox(height: 10),
                TextField(controller: _wa, decoration: const InputDecoration(labelText: "WhatsApp (com DDD)")),
                const SizedBox(height: 10),
                TextField(controller: _mat, decoration: const InputDecoration(labelText: "Matrícula")),
                const SizedBox(height: 10),
                TextField(
                  controller: _pass,
                  decoration: const InputDecoration(labelText: "Senha (mínimo 6)"),
                  obscureText: true,
                ),
                const SizedBox(height: 12),

                if (_err != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.25)),
                    ),
                    child: Text(_err!, style: const TextStyle(color: Colors.redAccent)),
                  ),

                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _loading ? null : _signup,
                  child: _loading
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text("Criar conta"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
