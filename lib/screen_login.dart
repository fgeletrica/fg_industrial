import 'core/sb.dart';

import "package:flutter/material.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "supabase_service.dart";
import "screen_signup.dart";
import "screen_home.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _mat = TextEditingController();
  final _pass = TextEditingController();

  bool _loading = false;
  String? _err;

  bool get _matOk => _mat.text.trim().length >= 3;
  bool get _passOk => _pass.text.trim().length >= 6;

  Future<void> _signIn() async {
    final matricula = _mat.text.trim();
    final pass = _pass.text.trim();

    if (!_matOk) return setState(() => _err = "Digite uma matrícula válida.");
    if (!_passOk) return setState(() => _err = "Senha mínima de 6 caracteres.");

    setState(() { _loading = true; _err = null; });

    try {
      final email = Sb.emailFromMatricula(matricula);
      await Sb.c.auth.signInWithPassword(email: email, password: pass);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
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
  Widget build(BuildContext context) {
    final canPress = !_loading && _matOk && _passOk;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.blueGrey.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text("Industrial • Login",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 14),

                  TextField(
                    controller: _mat,
                    decoration: const InputDecoration(
                      labelText: "Matrícula",
                      hintText: "ex: 6131450",
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _pass,
                    decoration: const InputDecoration(
                      labelText: "Senha",
                      hintText: "mínimo 6 caracteres",
                    ),
                    obscureText: true,
                    onChanged: (_) => setState(() {}),
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

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: canPress ? _signIn : null,
                          child: _loading
                              ? const SizedBox(
                                  height: 18, width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text("Entrar"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _loading ? null : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SignupScreen()),
                            );
                          },
                          child: const Text("Criar conta"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
