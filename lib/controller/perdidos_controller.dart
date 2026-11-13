import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../core/texto.dart';
import '../core/validadores.dart';
import '../model/animal_model.dart';
import '../model/pet_perdido_model.dart';
import 'auth_controller.dart';

enum FiltroPerdidos { todos, perdidos, encontrados }

/// Pets perdidos: anúncios em tempo real, busca, filtros e gravação.
class PerdidosController extends ChangeNotifier {
  PerdidosController(this._auth);

  final AuthController _auth;

  final CollectionReference<Map<String, dynamic>> _colecao =
      FirebaseFirestore.instance.collection('perdidos');

  static const _limite = Duration(seconds: 10);

  final buscaController = TextEditingController();

  String _busca = '';
  FiltroPerdidos _filtro = FiltroPerdidos.todos;
  bool _salvando = false;

  FiltroPerdidos get filtro => _filtro;
  bool get salvando => _salvando;

  String? get _uid => _auth.usuarioLogado?.uid;

  /// A ONG só acompanha os anúncios; não anuncia.
  bool get ehOng => _auth.usuarioLogado?.ehOng ?? false;

  bool ehAutor(PetPerdidoModel pet) => _uid != null && pet.autorUid == _uid;

  /// Quem pode marcar como encontrado: a ONG e quem anunciou.
  bool podeMarcar(PetPerdidoModel pet) => ehOng || ehAutor(pet);

  /// Todos os anúncios em tempo real: perdidos primeiro, mais recentes antes.
  Stream<List<PetPerdidoModel>> todos() {
    return _colecao.snapshots().map((snapshot) {
      final lista = snapshot.docs
          .map((doc) => PetPerdidoModel.fromMap(doc.id, doc.data()))
          .toList();

      lista.sort((a, b) {
        if (a.encontrado != b.encontrado) return a.encontrado ? 1 : -1;
        return b.dataDesaparecimento.compareTo(a.dataDesaparecimento);
      });
      return lista;
    });
  }

  // ---------- Busca e filtros ----------

  List<PetPerdidoModel> filtrar(List<PetPerdidoModel> lista) {
    final palavras = normalizarTexto(_busca)
        .split(' ')
        .where((palavra) => palavra.isNotEmpty)
        .toList();

    return lista.where((pet) {
      if (_filtro == FiltroPerdidos.perdidos && pet.encontrado) return false;
      if (_filtro == FiltroPerdidos.encontrados && !pet.encontrado) {
        return false;
      }
      if (palavras.isEmpty) return true;

      final texto = normalizarTexto(
        '${pet.nome} ${pet.especie.rotulo} ${pet.localVisto} ${pet.descricao}',
      );
      return palavras.every(texto.contains);
    }).toList();
  }

  void buscar(String texto) {
    _busca = texto;
    notifyListeners();
  }

  void definirFiltro(FiltroPerdidos novo) {
    _filtro = novo;
    notifyListeners();
  }

  void limpar() {
    reiniciar();
    notifyListeners();
  }

  /// Volta busca e filtro ao padrão, sem notificar (usado no initState).
  void reiniciar() {
    _busca = '';
    _filtro = FiltroPerdidos.todos;
    buscaController.clear();
  }

  // ---------- Validações do formulário ----------

  String? validarNome(String? valor) =>
      Validadores.tamanhoMinimo(valor, 2, campo: 'O nome');

  String? validarLocal(String? valor) =>
      Validadores.tamanhoMinimo(valor, 3, campo: 'O local');

  String? validarContato(String? valor) => Validadores.telefone(valor);

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

  /// RF003: publica o anúncio. Retorna `null` em caso de sucesso,
  /// ou a mensagem de erro.
  Future<String?> anunciar({
    required String nome,
    required Especie especie,
    required String local,
    required DateTime data,
    required String contato,
    String descricao = '',
    String fotoUrl = '',
  }) async {
    final usuario = _auth.usuarioLogado;
    if (usuario == null) return 'Sessão expirada. Entre novamente.';
    if (usuario.ehOng) return 'Contas de ONG apenas acompanham os anúncios.';

    _salvando = true;
    notifyListeners();

    try {
      await _colecao.add({
        'nome': nome.trim(),
        'especie': especie.name,
        'localVisto': local.trim(),
        'dataDesaparecimento': Timestamp.fromDate(data),
        'contato': contato.trim(),
        'descricao': descricao.trim(),
        'fotoUrl': fotoUrl.trim().isEmpty ? null : fotoUrl.trim(),
        'encontrado': false,
        'autorUid': usuario.uid,
        'autorNome': usuario.nome,
        'criadoEm': FieldValue.serverTimestamp(),
      }).timeout(_limite);
      return null;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return 'Sem permissão para anunciar. Confira as regras do Firestore.';
      }
      return 'Não foi possível publicar o anúncio. Tente novamente.';
    } catch (_) {
      return 'Não foi possível publicar o anúncio. '
          'Verifique a conexão e tente novamente.';
    } finally {
      _salvando = false;
      notifyListeners();
    }
  }

  /// Marca como encontrado (ou reabre a busca). Retorna `null` se der certo.
  Future<String?> alternarEncontrado(PetPerdidoModel pet) async {
    final usuario = _auth.usuarioLogado;
    if (usuario == null) return 'Sessão expirada. Entre novamente.';

    try {
      await _colecao.doc(pet.id).update({
        'encontrado': !pet.encontrado,
        'atualizadoEm': FieldValue.serverTimestamp(),
        'atualizadoPor': usuario.nome,
      }).timeout(_limite);
      return null;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return 'Você não tem permissão para alterar este anúncio.';
      }
      return 'Não foi possível atualizar. Tente novamente.';
    } catch (_) {
      return 'Não foi possível atualizar. Tente novamente.';
    }
  }

  /// Exclui o anúncio (só quem anunciou consegue).
  Future<String?> excluir(String id) async {
    try {
      await _colecao.doc(id).delete().timeout(_limite);
      return null;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return 'Só quem criou o anúncio pode excluí-lo.';
      }
      return 'Não foi possível excluir. Tente novamente.';
    } catch (_) {
      return 'Não foi possível excluir. Tente novamente.';
    }
  }

  @override
  void dispose() {
    buscaController.dispose();
    super.dispose();
  }
}