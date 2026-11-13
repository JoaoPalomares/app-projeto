/// Minúsculas, sem acento e sem hífen: "Siamês" e "siames" viram o mesmo texto.
String normalizarTexto(String texto) {
  const comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const semAcento = 'aaaaaeeeeiiiiooooouuuucn';

  final buffer = StringBuffer();
  for (final letra in texto.toLowerCase().split('')) {
    final posicao = comAcento.indexOf(letra);
    buffer.write(posicao >= 0 ? semAcento[posicao] : letra);
  }

  return buffer
      .toString()
      .replaceAll('-', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}