import 'package:flutter/material.dart';

import '../core/app_tema.dart';

/// Um passo (slide) do modal de introdução.
class PassoIntroducao {
  const PassoIntroducao({
    required this.icone,
    required this.cor,
    required this.titulo,
    required this.texto,
  });

  final IconData icone;
  final Color cor;
  final String titulo;
  final String texto;
}

/// Estado do modal de introdução: controla em qual passo o usuário está.
class IntroducaoController extends ChangeNotifier {
  static const passos = <PassoIntroducao>[
    PassoIntroducao(
      icone: Icons.pets,
      cor: AppCores.coral,
      titulo: 'Encontre seu novo amigo',
      texto: 'Navegue pelos animais disponíveis, filtre por espécie, porte '
          'e idade e inicie a adoção em poucos toques.',
    ),
    PassoIntroducao(
      icone: Icons.favorite_outline,
      cor: AppCores.verde,
      titulo: 'Cuide da saúde do seu pet',
      texto: 'Acompanhe vacinas, consultas e agende atendimentos '
          'veterinários sem sair do app.',
    ),
    PassoIntroducao(
      icone: Icons.search,
      cor: AppCores.turquesa,
      titulo: 'Ajude pets perdidos',
      texto: 'Veja os animais desaparecidos da região ou avise a '
          'comunidade quando encontrar um.',
    ),
  ];

  final pageController = PageController();
  int _passoAtual = 0;

  int get passoAtual => _passoAtual;
  bool get ultimoPasso => _passoAtual == passos.length - 1;

  void aoMudarPagina(int indice) {
    _passoAtual = indice;
    notifyListeners();
  }

  /// Avança um passo. Retorna `true` quando já estava no último
  /// (a view então fecha o modal).
  bool avancar() {
    if (ultimoPasso) return true;
    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    return false;
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}