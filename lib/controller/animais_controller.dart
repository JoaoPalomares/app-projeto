import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../model/animal_model.dart';
import 'auth_controller.dart';

/// Coleção `animais`: cadastro pelas ONGs e leitura em tempo real.
class AnimaisController extends ChangeNotifier {
  AnimaisController(this._auth);

  final AuthController _auth;

  final CollectionReference<Map<String, dynamic>> _colecao =
      FirebaseFirestore.instance.collection('animais');

  static const _limite = Duration(seconds: 10);

  bool _salvando = false;
  bool get salvando => _salvando;

  /// Todos os animais (será usado pela tela de Adoção), em tempo real.
  Stream<List<Animal>> todos() => _colecao.snapshots().map(_converter);

  /// Só os animais cadastrados pela ONG logada, em tempo real.
  Stream<List<Animal>> meus() {
    final uid = _auth.usuarioLogado?.uid;
    if (uid == null) return Stream.value(const []);

    return _colecao
        .where('ongUid', isEqualTo: uid)
        .snapshots()
        .map(_converter);
  }

  List<Animal> _converter(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final lista = snapshot.docs
        .map((doc) => Animal.fromMap(doc.id, doc.data()))
        .toList();
    lista.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    return lista;
  }

  // ---------- Validações do formulário ----------

  String? _obrigatorio(String? valor, String campo) {
    if (valor == null || valor.trim().isEmpty) return 'Informe $campo.';
    return null;
  }

  String? validarNome(String? valor) {
    final erro = _obrigatorio(valor, 'o nome do animal');
    if (erro != null) return erro;
    if (valor!.trim().length < 2) return 'O nome deve ter ao menos 2 letras.';
    return null;
  }

  String? validarRaca(String? valor) => _obrigatorio(valor, 'a raça');

  String? validarCidade(String? valor) => _obrigatorio(valor, 'a cidade');

  String? validarIdade(String? valor) {
    final erro = _obrigatorio(valor, 'a idade');
    if (erro != null) return erro;
    final numero = int.tryParse(valor!.trim());
    if (numero == null || numero < 1 || numero > 99) {
      return 'Use um número inteiro entre 1 e 99.';
    }
    return null;
  }

  String? validarDescricao(String? valor) {
    final erro = _obrigatorio(valor, 'uma descrição');
    if (erro != null) return erro;
    if (valor!.trim().length < 10) {
      return 'Descreva um pouco mais (mínimo de 10 letras).';
    }
    return null;
  }

  /// A foto é opcional; se preenchida, precisa ser um link http(s).
  String? validarLink(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return null;

    final uri = Uri.tryParse(texto);
    final valido = uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    return valido
        ? null
        : 'Informe um link válido, começando com http:// ou https://';
  }

  // ---------- Gravação ----------

  /// RF003: cadastra um animal. Retorna `null` em caso de sucesso,
  /// ou a mensagem de erro.
  Future<String?> cadastrar({
    required String nome,
    required Especie especie,
    required String raca,
    required int idadeMeses,
    required Porte porte,
    required Sexo sexo,
    required String cidade,
    required String descricao,
    required bool vacinado,
    required bool castrado,
    String fotoUrl = '',
  }) async {
    final usuario = _auth.usuarioLogado;
    if (usuario == null || !usuario.ehOng) {
      return 'Apenas contas de ONG podem cadastrar animais.';
    }

    _salvando = true;
    notifyListeners();

    try {
      final animal = Animal(
        id: '',
        nome: nome.trim(),
        especie: especie,
        raca: raca.trim(),
        idadeMeses: idadeMeses,
        porte: porte,
        sexo: sexo,
        cidade: cidade.trim(),
        ong: usuario.nome,
        descricao: descricao.trim(),
        vacinado: vacinado,
        castrado: castrado,
        fotoUrl: fotoUrl.trim().isEmpty ? null : fotoUrl.trim(),
        ongUid: usuario.uid,
      );

      await _colecao.add({
        ...animal.toMap(),
        'criadoEm': FieldValue.serverTimestamp(),
      }).timeout(_limite);
      return null;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return 'Sem permissão para cadastrar. Confira as regras do Firestore.';
      }
      return 'Não foi possível cadastrar o animal. Tente novamente.';
    } catch (_) {
      return 'Não foi possível cadastrar o animal. '
          'Verifique a conexão e tente novamente.';
    } finally {
      _salvando = false;
      notifyListeners();
    }
  }

  /// Exclui um animal da ONG. Retorna `null` em caso de sucesso.
  Future<String?> excluir(String id) async {
    try {
      await _colecao.doc(id).delete().timeout(_limite);
      return null;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return 'Você só pode excluir animais cadastrados pela sua ONG.';
      }
      return 'Não foi possível excluir. Tente novamente.';
    } catch (_) {
      return 'Não foi possível excluir. Tente novamente.';
    }
  }
}