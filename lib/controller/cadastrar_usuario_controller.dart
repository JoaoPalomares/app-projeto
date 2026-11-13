import 'package:flutter/material.dart';

import '../core/validadores.dart';
import 'auth_controller.dart';
import '../core/cnpj.dart';
import '../model/usuario_model.dart';

/// Estado e regras da tela de Cadastro de Usuário (RF002).
class CadastrarUsuarioController extends ChangeNotifier {
  CadastrarUsuarioController(this._auth);

  final AuthController _auth;

  bool _ocultarSenha = true;
  bool _ocultarConfirmacao = true;
  bool _carregando = false;
  String? _erro;

  bool get ocultarSenha => _ocultarSenha;
  bool get ocultarConfirmacao => _ocultarConfirmacao;
  bool get carregando => _carregando;
  String? get erro => _erro;

  void alternarVisibilidadeSenha() {
    _ocultarSenha = !_ocultarSenha;
    notifyListeners();
  }

  void alternarVisibilidadeConfirmacao() {
    _ocultarConfirmacao = !_ocultarConfirmacao;
    notifyListeners();
  }

  // Validações dos campos (1 a 3 do RF002).
  String? validarNome(String? valor) => Validadores.tamanhoMinimo(valor, 3, campo: 'O nome');

  String? validarEmail(String? valor) => Validadores.email(valor);

  String? validarTelefone(String? valor) => Validadores.telefone(valor);

  String? validarSenha(String? valor) => Validadores.senhaForte(valor);

  String? validarConfirmacao(String? valor, String senha) => Validadores.confirmacaoSenha(valor, senha);

  String? validarCidade(String? valor) {
    if (valor == null || valor.trim().length < 2) {
      return 'Informe a cidade da ONG.';
    }
    return null;
  }

  String? validarEstado(String? valor) {
    if (valor == null || valor.isEmpty) return 'Selecione.';
    return null;
  }

  String? validarCnpj(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Informe o CNPJ.';
    if (!cnpjValido(valor)) return 'CNPJ inválido. Confira os números.';
    return null;
  }

  String? validarDescricao(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Descreva brevemente o trabalho da ONG.';
    }
    if (valor.trim().length < 20) {
      return 'Escreva um pouco mais (mínimo de 20 letras).';
    }
    return null;
  }

    /// Cria a conta e já deixa o usuário logado.
  /// Retorna `true` se o cadastro foi concluído.
  Future<bool> cadastrar({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
    String tipo = Usuario.tipoAdotante,
    String cidade = '',
    String estado = '',
    String descricao = '',
    String cnpj = '',
  }) async {
    _erro = null;
    _carregando = true;
    notifyListeners();

    final erro = await _auth.cadastrar(
      nome: nome,
      email: email,
      telefone: telefone,
      senha: senha,
      tipo: tipo,
      cidade: cidade,
      estado: estado,
      descricao: descricao,
      cnpj: cnpj,
    );

    _carregando = false;
    _erro = erro;
    notifyListeners();
    return erro == null;
  }

  /// Limpa o estado da visita anterior (controller singleton).
  void reiniciar() {
    _ocultarSenha = true;
    _ocultarConfirmacao = true;
    _carregando = false;
    _erro = null;
  }
}
