import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/agendamento_model.dart';

/// Estado e regras da funcionalidade "Agendar".
///
/// Grava na coleção `agendamentos` do Firestore, com o `uid` do dono, e expõe
/// os agendamentos do usuário logado em tempo real (`streamAgendamentos`).
/// As regras do Firestore só deixam cada usuário acessar os próprios dados.
class AgendarController extends ChangeNotifier {
  static const List<String> servicos = [
    'Consulta veterinária',
    'Vacinação',
    'Banho e tosa',
    'Castração',
  ];

  // Horários fixos de atendimento (a cada 30 minutos).
  static final List<TimeOfDay> horariosManha = _gerarHorarios(8, 0, 8);
  static final List<TimeOfDay> horariosTarde = _gerarHorarios(13, 30, 9);

  static List<TimeOfDay> _gerarHorarios(int hora, int minuto, int quantidade) {
    return List.generate(quantidade, (i) {
      final total = hora * 60 + minuto + i * 30;
      return TimeOfDay(hour: total ~/ 60, minute: total % 60);
    });
  }

  static const _limite = Duration(seconds: 10);

  final CollectionReference<Map<String, dynamic>> _colecao =
      FirebaseFirestore.instance.collection('agendamentos');

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// Agendamentos do usuário logado, em tempo real, do mais próximo para o
  /// mais distante. Filtra só por `uid` (não exige índice composto) e ordena
  /// aqui.
  Stream<List<AgendamentoModel>> streamAgendamentos() {
    final uid = _uid;
    if (uid == null) return Stream.error('Sessão expirada. Entre novamente.');

    return _colecao.where('uid', isEqualTo: uid).snapshots().map((snap) {
      final lista = snap.docs.map(_paraAgendamento).toList()
        ..sort((a, b) => a.dataHora.compareTo(b.dataHora));
      return lista;
    });
  }

  AgendamentoModel _paraAgendamento(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final dados = doc.data();
    return AgendamentoModel(
      id: doc.id,
      nomePet: (dados['nomePet'] as String?) ?? '',
      servico: (dados['servico'] as String?) ?? '',
      dataHora:
          ((dados['dataHora'] as Timestamp?) ?? Timestamp.now()).toDate(),
      observacao: (dados['observacao'] as String?) ?? '',
    );
  }

  /// A clínica só atende de segunda a sexta.
  bool diaUtil(DateTime dia) =>
      dia.weekday != DateTime.saturday && dia.weekday != DateTime.sunday;

  /// Primeiro dia útil a partir de [data] (inclusive).
  DateTime primeiroDiaUtil(DateTime data) {
    var dia = DateTime(data.year, data.month, data.day);
    while (!diaUtil(dia)) {
      dia = dia.add(const Duration(days: 1));
    }
    return dia;
  }

  /// Horário indisponível: já passou, já foi agendado por você
  /// (lista [meus], vinda do Firestore) ou está ocupado por outro cliente
  /// (simulado para a demonstração).
  bool horarioIndisponivel(
    DateTime dia,
    TimeOfDay hora,
    List<AgendamentoModel> meus,
  ) {
    final inicio = combinar(dia, hora);
    if (!inicio.isAfter(DateTime.now())) return true;
    if (_ocupadoPorOutros(dia, hora)) return true;
    return meus.any((a) => a.dataHora.isAtSameMomentAs(inicio));
  }

  // Simula agendamentos de outros clientes (cerca de 1 horário em cada 6).
  bool _ocupadoPorOutros(DateTime dia, TimeOfDay hora) {
    final indice = (hora.hour * 60 + hora.minute - 8 * 60) ~/ 30;
    return (dia.day + dia.month + indice) % 6 == 0;
  }

  String? validarNomePet(String? valor) {
    final nome = valor?.trim() ?? '';
    if (nome.isEmpty) return 'O nome do pet é obrigatório';
    if (nome.length < 2) return 'O nome deve ter ao menos 2 caracteres';
    return null;
  }

  String? validarServico(String? valor) {
    if (valor == null || valor.isEmpty) return 'Escolha um serviço';
    return null;
  }

  /// Valida data e hora juntas: ambas obrigatórias e no futuro.
  String? validarDataHora(DateTime? data, TimeOfDay? hora) {
    if (data == null) return 'Escolha a data';
    if (hora == null) return 'Escolha o horário';
    if (!combinar(data, hora).isAfter(DateTime.now())) {
      return 'Escolha uma data e horário futuros';
    }
    return null;
  }

  DateTime combinar(DateTime data, TimeOfDay hora) =>
      DateTime(data.year, data.month, data.day, hora.hour, hora.minute);

  /// RF003: insere o agendamento. Retorna `null` se deu certo, ou a mensagem
  /// de erro.
  Future<String?> agendar({
    required String nomePet,
    required String servico,
    required DateTime data,
    required TimeOfDay hora,
    String observacao = '',
  }) async {
    final uid = _uid;
    if (uid == null) return 'Sessão expirada. Entre novamente.';

    try {
      await _colecao.add({
        'uid': uid,
        'nomePet': nomePet.trim(),
        'servico': servico,
        'dataHora': Timestamp.fromDate(combinar(data, hora)),
        'observacao': observacao.trim(),
        'criadoEm': FieldValue.serverTimestamp(),
      }).timeout(_limite);
      return null;
    } on FirebaseException catch (e) {
      debugPrint('Falha ao salvar agendamento: ${e.code} ${e.message}');
      if (e.code == 'permission-denied') {
        return 'Sem permissão para salvar. Entre novamente.';
      }
      return 'Não foi possível agendar. Tente novamente.';
    } catch (e) {
      debugPrint('Falha ao salvar agendamento: $e');
      return 'Não foi possível agendar. Verifique a conexão e tente '
          'novamente.';
    }
  }

  /// Cancela o agendamento. Retorna `null` se deu certo, ou a mensagem de erro.
  Future<String?> cancelar(String id) async {
    try {
      await _colecao.doc(id).delete().timeout(_limite);
      return null;
    } catch (e) {
      debugPrint('Falha ao cancelar agendamento: $e');
      return 'Não foi possível cancelar o agendamento. Tente novamente.';
    }
  }
}