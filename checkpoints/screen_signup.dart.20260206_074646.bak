import "../core/sb.dart";
import 'package:flutter/material.dart';
import '../core/sb.dart';

class ScreenSignup extends StatefulWidget {
  const ScreenSignup({super.key});

  @override
  State<ScreenSignup> createState() => _ScreenSignupState();
}

class _ScreenSignupState extends State<ScreenSignup> {
  final emailReal = TextEditingController(); // opcional (pra contato)
  final pass = TextEditingController();
  final matricula = TextEditingController();
  final fullName = TextEditingController();
  final siteCode = TextEditingController(text: 'DQX');

  bool _loading = false;
  bool _hide = true;

  String _emailFromMatricula(String m) {
    final onlyDigits = m.trim().replaceAll(RegExp(r'[^0-9]'), '');
    return '${onlyDigits}@fg-industrial.local';
  }

  Future<void> _signup() async {
    final mat = matricula.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
    final pw = pass.text;
    final name = fullName.text.trim();
    final sc = siteCode.text.trim().isEmpty
        ? 'DQX'
        : siteCode.text.trim().toUpperCase();
    final real = emailReal.text.trim();

    if (mat.length != 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Matrícula precisa ter 7 dígitos.')),
      );
      return;
    }
    if (pw.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Senha precisa ter pelo menos 6 caracteres.'),
        ),
      );
      return;
    }
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Informe o nome completo.')));
      return;
    }

    setState(() => _loading = true);
    try {
      final authEmail = _emailFromMatricula(mat);

      await Sb.c.auth.signUp(
        email: authEmail,
        password: pw,
        // IMPORTANTE: isso vai pro user_metadata do Auth.
        // Sua trigger no banco deve copiar isso pra public.profiles.
        data: <String, dynamic>{
          'matricula': mat,
          'full_name': name,
          'site_code': sc,
          'email_real': real,
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta criada! Agora é só entrar.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao criar conta: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    emailReal.dispose();
    pass.dispose();
    matricula.dispose();
    fullName.dispose();
    siteCode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cs.surface, cs.surfaceContainerHighest],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 10,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'FG Industrial',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'A conta é criada com email interno da matrícula.\nVocê entra depois com a matrícula + senha.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onSurface.withOpacity(.75),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: matricula,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Matrícula (7 dígitos)',
                                prefixIcon: Icon(Icons.badge_outlined),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 120,
                            child: TextField(
                              controller: siteCode,
                              textCapitalization: TextCapitalization.characters,
                              decoration: const InputDecoration(
                                labelText: 'Site',
                                prefixIcon: Icon(Icons.factory_outlined),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: fullName,
                        decoration: const InputDecoration(
                          labelText: 'Nome completo',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: emailReal,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email (opcional, só para contato)',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: pass,
                        obscureText: _hide,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _hide = !_hide),
                            icon: Icon(
                              _hide ? Icons.visibility : Icons.visibility_off,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: _loading ? null : _signup,
                          icon: _loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.person_add_alt_1),
                          label: Text(_loading ? 'Criando...' : 'Criar conta'),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
