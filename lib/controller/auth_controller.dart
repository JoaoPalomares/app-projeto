import 'package:flutter/foundation.dart';

import '../model/usuario_model.dart';

/// Estado de sessão do app: usuários cadastrados e usuário logado.
///
/// É compartilhado por Login, Cadastro, Recuperar senha e Perfil. Quando o
/// Perfil alterar o nome, quem ouvir este controller é atualizado.
///
/// Nesta etapa os dados ficam só em memória (mock), como o enunciado permite.
class AuthController extends ChangeNotifier {
  bool introducaoVista = false;

  final List<Usuario> _usuarios = [
    Usuario(
      nome: 'Usuário Teste',
      email: 'teste@miaudote.com',
      telefone: '(16) 99999-0000',
      senha: '123456',
    ),
  ];

  Usuario? _usuarioLogado;

  Usuario? get usuarioLogado => _usuarioLogado;
  bool get autenticado => _usuarioLogado != null;

  String _normalizar(String email) => email.trim().toLowerCase();

  bool emailCadastrado(String email) {
    final procurado = _normalizar(email);
    return _usuarios.any((u) => _normalizar(u.email) == procurado);
  }

  /// Retorna `true` se as credenciais conferem com algum usuário cadastrado.
  Future<bool> login(String email, String senha) async {
    // Simula o tempo de uma chamada à API.
    await Future.delayed(const Duration(milliseconds: 700));

    final procurado = _normalizar(email);
    final encontrados = _usuarios.where(
      (u) => _normalizar(u.email) == procurado && u.senha == senha,
    );

    if (encontrados.isEmpty) return false;

    _usuarioLogado = encontrados.first;
    notifyListeners();
    return true;
  }

  /// Cadastra e já loga o novo usuário (RF002: "permitir seu acesso ao app").
  /// Retorna `false` se o e-mail já estiver em uso.
  Future<bool> cadastrar({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (emailCadastrado(email)) return false;

    final novo = Usuario(
      nome: nome.trim(),
      email: email.trim(),
      telefone: telefone.trim(),
      senha: senha,
    );
    _usuarios.add(novo);
    _usuarioLogado = novo;
    notifyListeners();
    return true;
  }

  /// Atualiza o nome do usuário logado (usado pela tela de Perfil).
  /// Quem ouve este controller é reconstruído com o novo nome.
  void atualizarNome(String nome) {
    if (_usuarioLogado == null) return;
    _usuarioLogado!.nome = nome.trim();
    notifyListeners();
  }

  void logout() {
    _usuarioLogado = null;
    introducaoVista = false;
    notifyListeners();
  }
}