import 'package:flutter/material.dart';

import '../../core/app_tema.dart';

/// Logotipo do Miaudote (imagem com o desenho e o nome).
///
/// O arquivo tem margens brancas grandes; os fatores abaixo recortam só o
/// desenho. Se o logo ficar cortado, aumente os fatores (máximo 1.0).
class LogoMiaudote extends StatelessWidget {
  const LogoMiaudote({super.key, this.largura = 220});

  /// Largura visível do logotipo, já sem as margens.
  final double largura;

  static const double _fatorLargura = 0.52;
  static const double _fatorAltura = 0.62;

  @override
  Widget build(BuildContext context) {
    final larguraImagem = largura / _fatorLargura;

    return ClipRect(
      child: Align(
        widthFactor: _fatorLargura,
        heightFactor: _fatorAltura,
        child: Image.asset(
          'assets/images/logo-miaudote.jpg',
          width: larguraImagem,
          semanticLabel: 'Logotipo do Miaudote',
          // Se o arquivo não for encontrado, mostra um coração no lugar.
          errorBuilder: (context, erro, stack) => SizedBox(
            width: larguraImagem,
            height: larguraImagem * 0.56,
            child: const Center(
              child: Icon(Icons.favorite, color: AppCores.coral, size: 56),
            ),
          ),
        ),
      ),
    );
  }
}

/// Faixa vermelha com a mensagem de erro de uma operação (ex.: login inválido).
class MensagemErro extends StatelessWidget {
  const MensagemErro(this.mensagem, {super.key});

  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensagem,
              style: const TextStyle(color: Color(0xFFB91C1C)),
            ),
          ),
        ],
      ),
    );
  }
}