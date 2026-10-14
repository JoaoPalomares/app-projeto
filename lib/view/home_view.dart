import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/adocao_controller.dart';
import '../controller/auth_controller.dart';
import '../core/app_tema.dart';
import '../core/dependencias.dart'; // onde está o `g`
import 'adocao_view.dart';
import 'introducao_modal.dart';
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
    const _EmBreve(titulo: 'Meu Pet', icone: Icons.pets),
    const _EmBreve(titulo: 'Agendamentos', icone: Icons.calendar_month),
    const _EmBreve(titulo: 'Pets Perdidos', icone: Icons.location_on),
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
      body: IndexedStack(index: _indice, children: _abas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (indice) => setState(() => _indice = indice),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFFBE3DC),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite, color: AppCores.coral),
            label: 'Adoção',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets, color: AppCores.coral),
            label: 'Meu Pet',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month, color: AppCores.coral),
            label: 'Agendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on, color: AppCores.coral),
            label: 'Perdidos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppCores.coral),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

/// Aba provisória, até a tela real existir. Troque na lista `_abas`.
class _EmBreve extends StatelessWidget {
  const _EmBreve({required this.titulo, required this.icone});

  final String titulo;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 64, color: AppCores.borda),
            const SizedBox(height: 12),
            const Text('Tela em construção'),
          ],
        ),
      ),
    );
  }
}