import 'package:flutter/material.dart';

import '../core/validadores.dart';
import '../model/usuario_model.dart';
import 'auth_controller.dart';

/// Estado da tela de Perfil (RF005): alterna entre visualização e edição.
class PerfilController extends ChangeNotifier {
  PerfilController(this._auth);

  final AuthController _auth;

  bool _salvando = false;
  bool _editando = false;

  bool get salvando => _salvando;
  bool get editando => _editando;
  Usuario? get usuario => _auth.usuarioLogado;

  /// Volta ao modo de visualização sem notificar (chamado no initState).
  void reiniciar() => _editando = false;

  void iniciarEdicao() {
    _editando = true;
    notifyListeners();
  }

  void cancelarEdicao() {
    _editando = false;
    notifyListeners();
  }

  String? validarNome(String? valor) =>
      Validadores.tamanhoMinimo(valor, 3, campo: 'O nome');

  /// Grava o novo nome no Firestore. Retorna `null` em caso de sucesso,
  /// ou a mensagem de erro (a tela continua em modo de edição).
  Future<String?> salvar(String nome) async {
    if (!_auth.autenticado) return 'Sessão expirada. Entre novamente.';

    _salvando = true;
    notifyListeners();

    final erro = await _auth.atualizarNome(nome);

    _salvando = false;
    if (erro == null) _editando = false;
    notifyListeners();
    return erro;
  }
}