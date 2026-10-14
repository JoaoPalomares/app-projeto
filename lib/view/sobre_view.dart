import 'package:flutter/material.dart';

import '../controller/sobre_controller.dart';
import '../core/app_tema.dart';
import '../core/dependencias.dart';
import 'componentes/componentes_auth.dart';

class SobreView extends StatelessWidget {
  const SobreView({super.key});

  @override
  Widget build(BuildContext context) {
    final sobre = g<SobreController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Sobre')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: LogoMiaudote(largura: 200)),
                  const SizedBox(height: 8),
                  Text(
                    'Versão ${sobre.versao}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppCores.textoSuave),
                  ),
                  const SizedBox(height: 24),
                  _Secao(
                    titulo: 'Objetivo',
                    icone: Icons.flag_outlined,
                    filhos: [
                      Text(sobre.objetivo, style: const TextStyle(height: 1.5)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _Secao(
                    titulo: 'Equipe de desenvolvimento',
                    icone: Icons.groups_outlined,
                    filhos: [
                      for (final nome in sobre.integrantes)
                        _Linha(icone: Icons.person_outline, texto: nome),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _Secao(
                    titulo: 'Projeto acadêmico',
                    icone: Icons.school_outlined,
                    filhos: [
                      _Linha(
                        icone: Icons.menu_book_outlined,
                        texto: 'Disciplina: ${sobre.disciplina}',
                      ),
                      _Linha(
                        icone: Icons.person_pin_outlined,
                        texto: 'Professor: ${sobre.professor}',
                      ),
                      _Linha(
                        icone: Icons.account_balance_outlined,
                        texto: sobre.instituicao,
                      ),
                      _Linha(
                        icone: Icons.computer_outlined,
                        texto: sobre.curso,
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

/// Cartão com título e conteúdo.
class _Secao extends StatelessWidget {
  const _Secao({
    required this.titulo,
    required this.icone,
    required this.filhos,
  });

  final String titulo;
  final IconData icone;
  final List<Widget> filhos;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppCores.borda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, color: AppCores.coral),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppCores.texto,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...filhos,
        ],
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha({required this.icone, required this.texto});

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icone, size: 18, color: AppCores.verde),
          const SizedBox(width: 8),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }
}