import 'package:app_projeto/controller/cadastrar_usuario_controller.dart';
import 'package:app_projeto/controller/login_controller.dart';
import 'package:app_projeto/controller/perfil_controller.dart';
import 'package:app_projeto/controller/recuperar_senha_controller.dart';
import 'package:app_projeto/controller/sobre_controller.dart';
import 'package:get_it/get_it.dart';

final g = GetIt.instance;

void configurarDependencias(){
  g.registerSingleton<CadastrarUsuarioController>(
    CadastrarUsuarioController()
  );

  g.registerSingleton<LoginController>(
    LoginController()
  );

  g.registerSingleton<PerfilController>(
    PerfilController()
  );

  g.registerSingleton<RecuperarSenhaController>(
    RecuperarSenhaController()
  );

  g.registerSingleton<SobreController>(
    SobreController()
  );
}