String matriculaToEmail(String matricula) {
  final m = matricula.trim();
  return '$m@fg-industrial.local';
}

bool looksLikeEmail(String s) => s.contains('@');
