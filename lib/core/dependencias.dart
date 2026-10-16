import 'package:app_projeto/controller/auth_controller.dart';
import 'package:app_projeto/controller/cadastrar_usuario_controller.dart';
import 'package:app_projeto/controller/login_controller.dart';
import 'package:app_projeto/controller/perfil_controller.dart';
import 'package:app_projeto/controller/recuperar_senha_controller.dart';
import 'package:app_projeto/controller/sobre_controller.dart';
import 'package:get_it/get_it.dart';
import 'package:app_projeto/controller/agendar_controller.dart';
import 'package:app_projeto/controller/meu_pet_controller.dart';
import 'package:app_projeto/controller/perdidos_controller.dart';

final g = GetIt.instance;

void configurarDependencias(){
  // Estado de sessão compartilhado (usuários cadastrados e usuário logado).
  g.registerSingleton<AuthController>(
    AuthController()
  );

  g.registerSingleton<CadastrarUsuarioController>(
    CadastrarUsuarioController(g<AuthController>())
  );

  g.registerSingleton<LoginController>(
    LoginController(g<AuthController>())
  );

    g.registerSingleton<PerfilController>(
    PerfilController(g<AuthController>())
  );

  g.registerSingleton<RecuperarSenhaController>(
    RecuperarSenhaController(g<AuthController>())
  );

  g.registerSingleton<SobreController>(
    SobreController()
  );

  g.registerSingleton<AgendarController>(
    AgendarController()
  );

  g.registerSingleton<MeuPetController>(
    MeuPetController()
  );

  g.registerSingleton<PerdidosController>(
    PerdidosController()
  );
}