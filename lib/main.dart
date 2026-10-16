import 'package:provider/provider.dart';

import 'controller/triagem_controller.dart';
import 'model/animal_model.dart';
import 'view/triagem_view.dart';

import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:flutter/material.dart';

import 'core/app_routes.dart';
import 'core/app_tema.dart';
import 'core/dependencias.dart';
import 'view/cadastrar_usuario_view.dart';
import 'view/home_view.dart';
import 'view/login_view.dart';
import 'view/perfil_view.dart';
import 'view/recuperar_senha_view.dart';
import 'view/sobre_view.dart';

void main() {
  configurarDependencias();

  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Miaudote',
      theme: AppTema.claro,
      // Temporário. Depois do login pronto, volte para AppRoutes.login.
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.cadastrarUsuario: (context) => const CadastrarUsuarioView(),
        AppRoutes.home: (context) => const HomeView(),
        AppRoutes.login: (context) => const LoginView(),
        AppRoutes.perfil: (context) => const PerfilView(),
        AppRoutes.recuperarSenha: (context) => const RecuperarSenhaView(),
        AppRoutes.sobre: (context) => const SobreView(),

        AppRoutes.triagem: (context) {
          // O animal chega pelo "arguments" do Navigator.pushNamed da Adoção.
          final animal = ModalRoute.of(context)!.settings.arguments as Animal;
          return ChangeNotifierProvider(
            create: (_) => TriagemController(animal),
            child: const TriagemView(),
          );
        },
      },
    );
  }
}