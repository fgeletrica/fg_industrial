import 'package:flutter/material.dart';
import '../supabase_service.dart';
import '../core/login_helpers.dart';
import 'screen_signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _logoCtl;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;

  final matricula = TextEditingController();
  final pass = TextEditingController();
  bool _loading = false;
  bool _showPass = false;

  @override
  void initState() {
    super.initState();
    _logoCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    final curve = CurvedAnimation(parent: _logoCtl, curve: Curves.easeOutCubic);
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(curve);
    _logoScale = Tween<double>(begin: 0.92, end: 1.0).animate(curve);
    _logoCtl.forward();
  }

  double _logoSize(BuildContext context) {
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    if (shortest < 600) return 72; // phone
    if (shortest < 900) return 84; // tablet/janela média
    return 96; // desktop
  }

  Future<void> _signIn() async {
    setState(() => _loading = true);
    try {
      final m = matricula.text.trim();
      final p = pass.text;

      if (m.isEmpty || p.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preencha matrícula e senha.')),
        );
        return;
      }

      final emailLogin = (m.contains('@') ? m : matriculaToEmail(m));
      await Sb.c.auth.signInWithPassword(email: emailLogin, password: p);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Falha no login: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _logoCtl.dispose();
    matricula.dispose();
    pass.dispose();
    super.dispose();
  }

  Widget _cocaHeader(BuildContext context, {required String subtitle}) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FadeTransition(
              opacity: _logoFade,
              child: ScaleTransition(
                scale: _logoScale,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/brand/coca_cola_andina.png',
                    height: _logoSize(context),
                    width: _logoSize(context),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coca-Cola Andina • DQX',
                    style: (tt.titleMedium ?? const TextStyle(fontSize: 16))
                        .copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: (tt.bodySmall ?? const TextStyle(fontSize: 12))
                        .copyWith(
                          color: cs.onSurface.withOpacity(0.72),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 3,
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Entrar')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _cocaHeader(context, subtitle: 'Login • Acesso'),

                    // IGUAL ao Signup: FG Industrial abaixo da linha vermelha
                    const SizedBox(height: 14),
                    Text(
                      'FG Industrial',
                      textAlign: TextAlign.center,
                      style: (tt.headlineSmall ?? const TextStyle(fontSize: 22))
                          .copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Acesse com sua matrícula',
                      textAlign: TextAlign.center,
                      style: (tt.bodyMedium ?? const TextStyle(fontSize: 14))
                          .copyWith(
                            color: cs.onSurface.withOpacity(0.72),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: matricula,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Matrícula',
                        prefixIcon: Icon(Icons.badge),
                      ),
                      onSubmitted: (_) => _signIn(),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: pass,
                      obscureText: !_showPass,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _showPass = !_showPass),
                          icon: Icon(
                            _showPass ? Icons.visibility_off : Icons.visibility,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _signIn(),
                    ),
                    const SizedBox(height: 14),

                    SizedBox(
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: _loading ? null : _signIn,
                        icon: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.login),
                        label: Text(_loading ? 'Entrando...' : 'Entrar'),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _loading
                            ? null
                            : () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ScreenSignup(),
                                ),
                              ),
                        child: const Text('Criar conta'),
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
