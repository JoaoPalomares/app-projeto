import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/solicitacao_adocao_model.dart';
import 'auth_controller.dart';

/// Coleção `solicitacoes`: envio pelo adotante e resposta pela ONG.
class SolicitacoesController {
  SolicitacoesController(this._auth);

  final AuthController _auth;

  final CollectionReference<Map<String, dynamic>> _colecao =
      FirebaseFirestore.instance.collection('solicitacoes');

  static const _limite = Duration(seconds: 10);

  /// Pedidos feitos para os animais da ONG logada, em tempo real.
  Stream<List<Solicitacao>> daOng() => _ouvir('ongUid');

  /// Pedidos enviados pelo adotante logado, em tempo real.
  Stream<List<Solicitacao>> doAdotante() => _ouvir('adotanteUid');

  /// Quantidade de pedidos da ONG que ainda aguardam resposta.
  Stream<int> pendentesDaOng() => daOng().map(
        (lista) => lista.where((s) => s.status == Solicitacao.pendente).length,
      );

  Stream<List<Solicitacao>> _ouvir(String campo) {
    final uid = _auth.usuarioLogado?.uid;
    if (uid == null) return Stream.value(const []);

    return _colecao.where(campo, isEqualTo: uid).snapshots().map((snapshot) {
      final lista = snapshot.docs
          .map((doc) => Solicitacao.fromMap(doc.id, doc.data()))
          .toList();

      // Mais recentes primeiro (feito aqui para não precisar de índice).
      final agora = DateTime.now();
      lista.sort(
        (a, b) => (b.criadoEm ?? agora).compareTo(a.criadoEm ?? agora),
      );
      return lista;
    });
  }

  /// RF003: grava a solicitação. Retorna `null` em caso de sucesso,
  /// ou a mensagem de erro.
  Future<String?> enviar(SolicitacaoAdocao dados) async {
    final usuario = _auth.usuarioLogado;
    if (usuario == null) return 'Sessão expirada. Entre novamente.';
    if (usuario.ehOng) return 'Contas de ONG não podem solicitar adoção.';
    if (dados.animal.ongUid == null) {
      return 'Este animal não está vinculado a uma ONG.';
    }

    // Id fixo (adotante + animal): impede pedidos repetidos para o mesmo animal.
    final id = '${usuario.uid}_${dados.animal.id}';

    try {
      await _colecao.doc(id).set({
        ...dados.toMap(adotanteUid: usuario.uid),
        'status': Solicitacao.pendente,
        'criadoEm': FieldValue.serverTimestamp(),
      }).timeout(_limite);
      return null;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return 'Não foi possível enviar. Se você já pediu a adoção deste '
            'animal, acompanhe em Perfil > Minhas solicitações.';
      }
      return 'Não foi possível enviar a solicitação. Tente novamente.';
    } catch (_) {
      return 'Não foi possível enviar a solicitação. '
          'Verifique a conexão e tente novamente.';
    }
  }

  /// Aprova ou recusa um pedido (só a ONG dona do animal consegue).
  Future<String?> responder(String id, String status) async {
    try {
      await _colecao.doc(id).update({
        'status': status,
        'respondidoEm': FieldValue.serverTimestamp(),
      }).timeout(_limite);
      return null;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return 'Você não tem permissão para responder a este pedido.';
      }
      return 'Não foi possível salvar a resposta. Tente novamente.';
    } catch (_) {
      return 'Não foi possível salvar a resposta. Tente novamente.';
    }
  }
}