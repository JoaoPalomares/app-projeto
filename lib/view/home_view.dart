import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/adocao_controller.dart';
import '../controller/auth_controller.dart';
import '../core/app_tema.dart';
import '../core/dependencias.dart'; // onde está o `g`
import 'adocao_view.dart';
import 'agendamento_view.dart';
import 'introducao_modal.dart';
import 'meu_pet_view.dart';
import 'perdidos_view.dart';
import 'perfil_view.dart';

/// Tela principal: guarda a barra de navegação inferior e as abas.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _indice = 0;

  // Criadas uma única vez. O IndexedStack mantém cada aba "viva", então a
  // busca e os filtros da Adoção não se perdem ao trocar de aba.
  late final List<Widget> _abas = [
    ChangeNotifierProvider(
      create: (_) => AdocaoController(),
      child: const AdocaoView(),
    ),
    const MeuPetView(),
    const AgendarView(),
    const PerdidosView(),
    const PerfilView(),
  ];

  @override
  void initState() {
    super.initState();
    // Espera o primeiro frame para ter um contexto pronto para o diálogo.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = g<AuthController>();
      if (!auth.introducaoVista) {
        auth.introducaoVista = true;
        mostrarIntroducao(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // O conteúdo passa por trás da barra, o que cria o efeito de vidro.
      extendBody: true,
      body: IndexedStack(index: _indice, children: _abas),
      bottomNavigationBar: _BarraFlutuante(
        indice: _indice,
        onSelecionar: (indice) => setState(() => _indice = indice),
      ),
    );
  }
}

class _ItemBarra {
  const _ItemBarra(this.icone, this.iconeAtivo, this.rotulo);

  final IconData icone;
  final IconData iconeAtivo;
  final String rotulo;
}

const _itensBarra = [
  _ItemBarra(Icons.favorite_border, Icons.favorite, 'Adoção'),
  _ItemBarra(Icons.pets_outlined, Icons.pets, 'Meu Pet'),
  _ItemBarra(Icons.calendar_month_outlined, Icons.calendar_month, 'Agendar'),
  _ItemBarra(Icons.location_on_outlined, Icons.location_on, 'Perdidos'),
  _ItemBarra(Icons.person_outline, Icons.person, 'Perfil'),
];

/// Barra de navegação flutuante com efeito de vidro fosco.
class _BarraFlutuante extends StatelessWidget {
  const _BarraFlutuante({required this.indice, required this.onSelecionar});

  final int indice;
  final ValueChanged<int> onSelecionar;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.8),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        for (var i = 0; i < _itensBarra.length; i++)
                          Expanded(
                            child: _ItemBarraWidget(
                              item: _itensBarra[i],
                              selecionado: i == indice,
                              onTap: () => onSelecionar(i),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemBarraWidget extends StatelessWidget {
  const _ItemBarraWidget({
    required this.item,
    required this.selecionado,
    required this.onTap,
  });

  final _ItemBarra item;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cor = selecionado ? AppCores.verde : AppCores.textoSuave;

    return Semantics(
      button: true,
      selected: selecionado,
      label: item.rotulo,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selecionado
                ? const Color.fromARGB(255, 224, 255, 255)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selecionado ? item.iconeAtivo : item.icone,
                size: 22,
                color: cor,
              ),
              const SizedBox(height: 2),
              Text(
                item.rotulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selecionado ? FontWeight.w600 : FontWeight.w400,
                  color: cor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}