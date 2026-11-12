import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/validadores.dart';
import '../model/pet_model.dart';

/// Estado e regras da funcionalidade "Meu Pet" (cadastrar, listar e remover).
///
/// RF003: grava na coleção `pets` do Firestore, com o `uid` do dono.
/// RF004: expõe os pets do usuário logado em tempo real (`streamPets`).
/// As regras do Firestore só deixam cada usuário acessar os próprios pets.
class MeuPetController extends ChangeNotifier {
  static const List<String> especies = ['Cachorro', 'Gato', 'Outro'];

  static const _limite = Duration(seconds: 10);

  final CollectionReference<Map<String, dynamic>> _colecao =
      FirebaseFirestore.instance.collection('pets');

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  String? validarNome(String? valor) =>
      Validadores.tamanhoMinimo(valor, 2, campo: 'O nome do pet');

  String? validarEspecie(String? valor) {
    if (valor == null || valor.isEmpty) return 'Escolha a espécie.';
    return null;
  }

  String? validarIdade(String? valor) {
    final vazio = Validadores.obrigatorio(
      valor,
      campo: 'A idade',
      feminino: true,
    );
    if (vazio != null) return vazio;

    final idade = int.tryParse(valor!.trim());
    if (idade == null || idade < 0 || idade > 40) {
      return 'Informe a idade em anos (0 a 40).';
    }
    return null;
  }

  /// Pets do usuário logado, em tempo real.
  /// Filtra só por `uid` (não exige índice composto) e ordena aqui, do mais
  /// novo para o mais antigo.
  Stream<List<PetModel>> streamPets() {
    final uid = _uid;
    if (uid == null) return Stream.error('Sessão expirada. Entre novamente.');

    return _colecao.where('uid', isEqualTo: uid).snapshots().map((snap) {
      // Logo após salvar, o serverTimestamp ainda é nulo no cache local.
      Timestamp criadoEm(QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
          (doc.data()['criadoEm'] as Timestamp?) ?? Timestamp.now();

      final docs = snap.docs.toList()
        ..sort((a, b) => criadoEm(b).compareTo(criadoEm(a)));
      return docs.map(_paraPet).toList();
    });
  }

  PetModel _paraPet(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final dados = doc.data();
    return PetModel(
      id: doc.id,
      nome: (dados['nome'] as String?) ?? '',
      especie: (dados['especie'] as String?) ?? '',
      idadeAnos: (dados['idadeAnos'] as num?)?.toInt() ?? 0,
      raca: (dados['raca'] as String?) ?? '',
      observacao: (dados['observacao'] as String?) ?? '',
    );
  }

  /// RF003: insere o pet. Retorna `null` se deu certo, ou a mensagem de erro.
  Future<String?> adicionar({
    required String nome,
    required String especie,
    required int idadeAnos,
    String raca = '',
    String observacao = '',
  }) async {
    final uid = _uid;
    if (uid == null) return 'Sessão expirada. Entre novamente.';

    try {
      await _colecao.add({
        'uid': uid,
        'nome': nome.trim(),
        'especie': especie,
        'idadeAnos': idadeAnos,
        'raca': raca.trim(),
        'observacao': observacao.trim(),
        'criadoEm': FieldValue.serverTimestamp(),
      }).timeout(_limite);
      return null;
    } on FirebaseException catch (e) {
      debugPrint('Falha ao salvar pet: ${e.code} ${e.message}');
      if (e.code == 'permission-denied') {
        return 'Sem permissão para salvar. Entre novamente.';
      }
      return 'Não foi possível salvar o pet. Tente novamente.';
    } catch (e) {
      debugPrint('Falha ao salvar pet: $e');
      return 'Não foi possível salvar o pet. Verifique a conexão e tente '
          'novamente.';
    }
  }

  /// Remove o pet. Retorna `null` se deu certo, ou a mensagem de erro.
  Future<String?> remover(String id) async {
    try {
      await _colecao.doc(id).delete().timeout(_limite);
      return null;
    } catch (e) {
      debugPrint('Falha ao remover pet: $e');
      return 'Não foi possível remover o pet. Tente novamente.';
    }
  }
}