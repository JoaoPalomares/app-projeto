import 'package:flutter/services.dart';

/// Máscara de telefone brasileiro enquanto o usuário digita.
///   10 dígitos (fixo):   (16) 3333-4444
///   11 dígitos (celular): (16) 99999-4444
class TelefoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue valorAntigo,
    TextEditingValue valorNovo,
  ) {
    var digitos = valorNovo.text.replaceAll(RegExp(r'\D'), '');
    if (digitos.length > 11) digitos = digitos.substring(0, 11);

    final texto = _aplicarMascara(digitos);

    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }

  String _aplicarMascara(String digitos) {
    if (digitos.isEmpty) return '';
    if (digitos.length <= 2) return '($digitos';

    final ddd = digitos.substring(0, 2);
    final numero = digitos.substring(2);

    if (numero.length <= 4) return '($ddd) $numero';

    // Celular (11 dígitos) separa depois do 5º dígito; fixo, depois do 4º.
    final corte = digitos.length == 11 ? 5 : 4;
    return '($ddd) ${numero.substring(0, corte)}-${numero.substring(corte)}';
  }
}