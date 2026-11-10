import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../model/usuario_model.dart';

/// Sessão do app, integrada ao Firebase Authentication e ao Firestore.
///
/// Os dados do perfil ficam na coleção `usuarios`, em um documento cujo id
/// é o uid do usuário. Os métodos retornam `null` em caso de sucesso, ou a
/// mensagem de erro (em português) para a tela exibir.
class AuthController extends ChangeNotifier {
  bool introducaoVista = false;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const _limite = Duration(seconds: 10);

  Usuario? _usuarioLogado;

  Usuario? get usuarioLogado => _usuarioLogado;
  bool get autenticado => _usuarioLogado != null;

  DocumentReference<Map<String, dynamic>> _docUsuario(String uid) =>
      _firestore.collection('usuarios').doc(uid);

  /// Chamado ao abrir o app: se o Firebase ainda guarda uma sessão,
  /// o usuário volta direto para a Home.
  Future<void> restaurarSessao() async {
    final user = await _firebaseAuth.authStateChanges().first;
    if (user == null) return;

    await _carregarUsuario(user);
    introducaoVista = true; // quem já estava logado não vê a introdução de novo
  }

  /// Busca o perfil no Firestore. Se falhar, usa os dados básicos do Auth.
  Future<void> _carregarUsuario(User user) async {
    Map<String, dynamic>? dados;
    try {
      final doc = await _docUsuario(user.uid).get().timeout(_limite);
      dados = doc.data();
    } catch (_) {
      dados = null;
    }

    _usuarioLogado = Usuario(
      uid: user.uid,
      nome: (dados?['nome'] as String?) ?? user.displayName ?? '',
      email: user.email ?? '',
      telefone: (dados?['telefone'] as String?) ?? '',
    );
  }

  /// RF001: login com e-mail e senha.
  Future<String?> login(String email, String senha) async {
    try {
      final cred = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );
      await _carregarUsuario(cred.user!);
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return _mensagemErro(e);
    } catch (_) {
      return 'Não foi possível entrar. Tente novamente.';
    }
  }

    /// Login com a conta Google. Retorna `null` em caso de sucesso
  /// (ou se o usuário apenas fechou o popup), ou a mensagem de erro.
  Future<String?> loginComGoogle() async {
    try {
      final provider = GoogleAuthProvider();
      final cred = kIsWeb
          ? await _firebaseAuth.signInWithPopup(provider)
          : await _firebaseAuth.signInWithProvider(provider);

      final user = cred.user!;
      await _garantirPerfil(user);
      await _carregarUsuario(user);
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      // O usuário fechou o popup: não é um erro, só não entra.
      if (e.code == 'popup-closed-by-user' ||
          e.code == 'cancelled-popup-request' ||
          e.code == 'canceled') {
        return null;
      }
      if (e.code == 'popup-blocked') {
        return 'O navegador bloqueou a janela do Google. Libere os popups.';
      }
      if (e.code == 'account-exists-with-different-credential') {
        return 'Já existe uma conta com este e-mail. Entre com e-mail e senha.';
      }
      return _mensagemErro(e);
    } catch (_) {
      return 'Não foi possível entrar com o Google. Tente novamente.';
    }
  }

  /// No primeiro acesso com Google, cria o documento em `usuarios/{uid}`,
  /// como o cadastro normal faz. Nos acessos seguintes não mexe em nada.
  Future<void> _garantirPerfil(User user) async {
    final ref = _docUsuario(user.uid);
    final doc = await ref.get().timeout(_limite);
    if (doc.exists) return;

    await ref.set({
      'uid': user.uid,
      'nome': user.displayName ?? '',
      'email': user.email ?? '',
      'telefone': '',
      'criadoEm': FieldValue.serverTimestamp(),
    }).timeout(_limite);
  }

  /// RF002: cria a conta no Authentication e grava os dados em `usuarios`.
  Future<String?> cadastrar({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
  }) async {
    User? novo;
    try {
      final cred = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );
      novo = cred.user!;

      await _docUsuario(novo.uid).set({
        'uid': novo.uid,
        'nome': nome.trim(),
        'email': email.trim(),
        'telefone': telefone.trim(),
        'criadoEm': FieldValue.serverTimestamp(),
      }).timeout(_limite);

      _usuarioLogado = Usuario(
        uid: novo.uid,
        nome: nome.trim(),
        email: email.trim(),
        telefone: telefone.trim(),
      );
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return _mensagemErro(e);
    } catch (_) {
      // A conta chegou a ser criada, mas o perfil não foi salvo: desfaz a conta
      // para o usuário não ficar com um cadastro pela metade.
      try {
        await novo?.delete();
      } catch (_) {}
      return 'Não foi possível concluir o cadastro. Tente novamente.';
    }
  }

  /// RF001: envia o e-mail de redefinição de senha.
  Future<String?> enviarRedefinicaoSenha(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'Não encontramos uma conta cadastrada com este e-mail.';
      }
      return _mensagemErro(e);
    } catch (_) {
      return 'Não foi possível enviar o e-mail. Tente novamente.';
    }
  }

  /// Atualiza o nome no Firestore (usado pela tela de Perfil).
  Future<String?> atualizarNome(String nome) async {
    final usuario = _usuarioLogado;
    if (usuario == null) return 'Sessão expirada. Entre novamente.';

    try {
      await _docUsuario(usuario.uid)
          .update({'nome': nome.trim()}).timeout(_limite);
      usuario.nome = nome.trim();
      notifyListeners();
      return null;
    } catch (_) {
      return 'Não foi possível salvar o nome. Tente novamente.';
    }
  }

  Future<void> logout() async {
    _usuarioLogado = null;
    introducaoVista = false;
    notifyListeners();
    await _firebaseAuth.signOut();
  }

  String _mensagemErro(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'weak-password':
        return 'A senha é muito fraca. Use ao menos 6 caracteres.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde um pouco e tente de novo.';
      case 'network-request-failed':
        return 'Sem conexão com a internet. Verifique e tente novamente.';
      case 'operation-not-allowed':
        return 'Login por e-mail e senha não está habilitado no Firebase.';
      default:
        return 'Não foi possível concluir a operação. Tente novamente.';
    }
  }
}