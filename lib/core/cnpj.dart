import 'package:flutter/services.dart';

/// Máscara de CNPJ: 00.000.000/0000-00
class CnpjInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue antigo,
    TextEditingValue novo,
  ) {
    final digitos = novo.text.replaceAll(RegExp(r'\D'), '');
    final limitado = digitos.length > 14 ? digitos.substring(0, 14) : digitos;

    final buffer = StringBuffer();
    for (var i = 0; i < limitado.length; i++) {
      if (i == 2 || i == 5) buffer.write('.');
      if (i == 8) buffer.write('/');
      if (i == 12) buffer.write('-');
      buffer.write(limitado[i]);
    }

    final texto = buffer.toString();
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}

/// Confere se o CNPJ tem 14 dígitos e se os dois dígitos verificadores batem.
bool cnpjValido(String texto) {
  final d = texto.replaceAll(RegExp(r'\D'), '');
  if (d.length != 14) return false;
  if (RegExp(r'^(\d)\1{13}$').hasMatch(d)) return false; // 00000000000000...

  int digito(List<int> pesos) {
    var soma = 0;
    for (var i = 0; i < pesos.length; i++) {
      soma += int.parse(d[i]) * pesos[i];
    }
    final resto = soma % 11;
    return resto < 2 ? 0 : 11 - resto;
  }

  final primeiro = digito([5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]);
  final segundo = digito([6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]);
  return primeiro == int.parse(d[12]) && segundo == int.parse(d[13]);
}