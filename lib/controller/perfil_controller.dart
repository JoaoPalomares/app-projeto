import 'package:flutter/material.dart';

import '../core/validadores.dart';
import 'auth_controller.dart';

/// Estado e regras da tela de Perfil do Usuário (RF005).
class PerfilController extends ChangeNotifier {
  PerfilController(this._auth);

  final AuthController _auth;

  bool _salvando = false;

  bool get salvando => _salvando;

  // Validações do nome (1 e 2 do RF005): preenchido e com tamanho mínimo.
  String? validarNome(String? valor) =>
      Validadores.tamanhoMinimo(valor, 3, campo: 'O nome');

  /// Atualiza o nome do usuário logado. O novo nome passa a ser usado pelas
  /// telas que identificam o usuário (elas ouvem o `AuthController`).
  Future<void> salvar(String nome) async {
    if (!_auth.autenticado) return;

    _salvando = true;
    notifyListeners();

    // Simula a chamada à API.
    await Future.delayed(const Duration(milliseconds: 500));
    _auth.atualizarNome(nome);

    _salvando = false;
    notifyListeners();
  }
}