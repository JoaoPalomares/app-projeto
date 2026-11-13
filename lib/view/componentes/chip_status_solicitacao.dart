import 'package:flutter/material.dart';

import '../../model/solicitacao_adocao_model.dart';

/// Selo colorido com o status da solicitação.
class ChipStatusSolicitacao extends StatelessWidget {
  const ChipStatusSolicitacao({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (texto, fundo, corTexto, icone) = switch (status) {
      Solicitacao.aprovada => (
          'Aprovada',
          const Color(0xFFDCFCE7),
          const Color(0xFF166534),
          Icons.check_circle_outline,
        ),
      Solicitacao.recusada => (
          'Recusada',
          const Color(0xFFFEE2E2),
          const Color(0xFF991B1B),
          Icons.cancel_outlined,
        ),
      _ => (
          'Pendente',
          const Color(0xFFFEF3C7),
          const Color(0xFF92400E),
          Icons.schedule,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 14, color: corTexto),
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: corTexto,
            ),
          ),
        ],
      ),
    );
  }
}