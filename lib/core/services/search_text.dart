/// Normalização compartilhada pela busca e pelos termos recentes.
String normalizeSearchText(String value) {
  const accented = 'àáâãäåèéêëìíîïòóôõöùúûüçñýÿ';
  const plain = 'aaaaaaeeeeiiiiooooouuuucnyy';
  final lower = value.toLowerCase().replaceAll(RegExp(r'[\u0300-\u036f]'), '');
  return lower
      .split('')
      .map((letter) {
        final index = accented.indexOf(letter);
        return index < 0 ? letter : plain[index];
      })
      .join()
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');
}

String cleanSearchTerm(String value) =>
    value.trim().replaceAll(RegExp(r'\s+'), ' ');
