import 'package:flutter/material.dart';

import '../core/validadores.dart';
import 'auth_controller.dart';

/// Estado e regras da tela de Login (RF001).
class LoginController extends ChangeNotifier {
  LoginController(this._auth);

  final AuthController _auth;

  bool _ocultarSenha = true;
  bool _carregando = false;
  String? _erro;

  bool get ocultarSenha => _ocultarSenha;
  bool get carregando => _carregando;
  String? get erro => _erro;

  void alternarVisibilidadeSenha() {
    _ocultarSenha = !_ocultarSenha;
    notifyListeners();
  }

  // Validações dos campos (1 e 2 do RF001).
  String? validarEmail(String? valor) => Validadores.email(valor);

  String? validarSenha(String? valor) =>
      Validadores.obrigatorio(valor, campo: 'A senha', feminino: true);

    /// Tenta autenticar. Retorna `true` se as credenciais estiverem corretas.
  Future<bool> entrar(String email, String senha) async {
    _erro = null;
    _carregando = true;
    notifyListeners();

    final erro = await _auth.login(email, senha);

    _carregando = false;
    _erro = erro;
    notifyListeners();
    return erro == null;
  }

    /// Login com Google. Retorna `true` só se o usuário realmente entrou
  /// (fechar o popup não conta como erro nem como login).
  Future<bool> entrarComGoogle() async {
    _erro = null;
    _carregando = true;
    notifyListeners();

    final erro = await _auth.loginComGoogle();

    _carregando = false;
    _erro = erro;
    notifyListeners();
    return erro == null && _auth.autenticado;
  }

  /// Como o controller é singleton, a tela chama isto ao abrir para limpar
  /// o estado da visita anterior (não notifica: ainda não há tela ouvindo).
  void reiniciar() {
    _ocultarSenha = true;
    _carregando = false;
    _erro = null;
  }
}