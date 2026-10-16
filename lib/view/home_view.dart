import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/adocao_controller.dart';
import '../controller/auth_controller.dart';
import '../core/app_tema.dart';
import '../core/dependencias.dart'; // onde está o `g`
import 'adocao_view.dart';
import 'introducao_modal.dart';
import 'perfil_view.dart';
import 'agendamento_view.dart';
import 'meu_pet_view.dart';
import 'perdidos_view.dart';

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