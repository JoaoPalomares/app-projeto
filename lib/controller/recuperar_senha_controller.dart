import 'package:flutter/material.dart';

import '../core/validadores.dart';
import 'auth_controller.dart';

/// Estado e regras da tela "Esqueceu a senha" (RF003).
class RecuperarSenhaController extends ChangeNotifier {
  RecuperarSenhaController(this._auth);

  final AuthController _auth;

  bool _carregando = false;
  String? _erro;

  bool get carregando => _carregando;
  String? get erro => _erro;

  // Validação do campo (1 e 2 do RF003).
  String? validarEmail(String? valor) => Validadores.email(valor);

  /// Simula o envio das instruções de redefinição.
  /// Retorna `true` se o e-mail estiver associado a uma conta cadastrada.
  Future<bool> solicitar(String email) async {
    _erro = null;
    _carregando = true;
    notifyListeners();

    // Simula o envio do e-mail pela API.
    await Future.delayed(const Duration(milliseconds: 800));
    final cadastrado = _auth.emailCadastrado(email);

    _carregando = false;
    if (!cadastrado) {
      _erro = 'Não encontramos uma conta cadastrada com este e-mail.';
    }
    notifyListeners();
    return cadastrado;
  }

  /// Limpa o estado da visita anterior (controller singleton).
  void reiniciar() {
    _carregando = false;
    _erro = null;
  }
}