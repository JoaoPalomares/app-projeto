import 'package:cloud_firestore/cloud_firestore.dart';

import 'animal_model.dart';

/// Dados preenchidos no formulário de triagem (RF05 - Processo de adoção).
class SolicitacaoAdocao {
  const SolicitacaoAdocao({
    required this.animal,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.endereco,
    required this.experiencia,
    required this.moradia,
    required this.horasSozinho,
    required this.outrosPets,
    required this.motivacao,
  });

  final Animal animal;
  final String nome;
  final String email;
  final String telefone;
  final String endereco;
  final String experiencia;
  final String moradia;
  final String horasSozinho;
  final String outrosPets;
  final String motivacao;

  /// Campos gravados em `solicitacoes` (status e data são acrescentados
  /// pelo controller).
  Map<String, dynamic> toMap({required String adotanteUid}) => {
        'adotanteUid': adotanteUid,
        'nome': nome,
        'email': email,
        'telefone': telefone,
        'endereco': endereco,
        'experiencia': experiencia,
        'moradia': moradia,
        'horasSozinho': horasSozinho,
        'outrosPets': outrosPets,
        'motivacao': motivacao,
        'animalId': animal.id,
        'animalNome': animal.nome,
        'ongUid': animal.ongUid,
        'ongNome': animal.ong,
      };
}

/// Solicitação já gravada no Firestore (lida em tempo real pelas telas).
class Solicitacao {
  const Solicitacao({
    required this.id,
    required this.adotanteUid,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.endereco,
    required this.experiencia,
    required this.moradia,
    required this.horasSozinho,
    required this.outrosPets,
    required this.motivacao,
    required this.animalId,
    required this.animalNome,
    required this.ongUid,
    required this.ongNome,
    required this.status,
    this.criadoEm,
  });

  static const pendente = 'pendente';
  static const aprovada = 'aprovada';
  static const recusada = 'recusada';

  final String id;
  final String adotanteUid;
  final String nome;
  final String email;
  final String telefone;
  final String endereco;
  final String experiencia;
  final String moradia;
  final String horasSozinho;
  final String outrosPets;
  final String motivacao;
  final String animalId;
  final String animalNome;
  final String ongUid;
  final String ongNome;
  final String status;
  final DateTime? criadoEm;

  factory Solicitacao.fromMap(String id, Map<String, dynamic> d) {
    String texto(String campo) => d[campo] as String? ?? '';

    return Solicitacao(
      id: id,
      adotanteUid: texto('adotanteUid'),
      nome: texto('nome'),
      email: texto('email'),
      telefone: texto('telefone'),
      endereco: texto('endereco'),
      experiencia: texto('experiencia'),
      moradia: texto('moradia'),
      horasSozinho: texto('horasSozinho'),
      outrosPets: texto('outrosPets'),
      motivacao: texto('motivacao'),
      animalId: texto('animalId'),
      animalNome: texto('animalNome'),
      ongUid: texto('ongUid'),
      ongNome: texto('ongNome'),
      status: d['status'] as String? ?? pendente,
      criadoEm: (d['criadoEm'] as Timestamp?)?.toDate(),
    );
  }

  /// Data de envio no formato dd/mm/aaaa hh:mm.
  String get dataFormatada {
    final data = criadoEm;
    if (data == null) return 'agora';

    String dois(int n) => n.toString().padLeft(2, '0');
    return '${dois(data.day)}/${dois(data.month)}/${data.year} '
        '${dois(data.hour)}:${dois(data.minute)}';
  }
}