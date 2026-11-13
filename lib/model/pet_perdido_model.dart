import 'package:cloud_firestore/cloud_firestore.dart';

import 'animal_model.dart';

/// Anúncio de pet perdido (coleção `perdidos`).
class PetPerdidoModel {
  const PetPerdidoModel({
    required this.id,
    required this.nome,
    required this.especie,
    required this.localVisto,
    required this.dataDesaparecimento,
    required this.contato,
    required this.autorUid,
    required this.autorNome,
    this.descricao = '',
    this.fotoUrl,
    this.encontrado = false,
  });

  final String id;
  final String nome;
  final Especie especie;
  final String localVisto;
  final DateTime dataDesaparecimento;
  final String contato;
  final String descricao;

  /// Link de uma foto na internet, informado por quem anunciou.
  final String? fotoUrl;
  final bool encontrado;

  /// Quem anunciou.
  final String autorUid;
  final String autorNome;

  factory PetPerdidoModel.fromMap(String id, Map<String, dynamic> d) {
    final foto = d['fotoUrl'] as String?;

    return PetPerdidoModel(
      id: id,
      nome: d['nome'] as String? ?? '',
      especie: Especie.values.asNameMap()[d['especie']] ?? Especie.cachorro,
      localVisto: d['localVisto'] as String? ?? '',
      dataDesaparecimento:
          (d['dataDesaparecimento'] as Timestamp?)?.toDate() ?? DateTime.now(),
      contato: d['contato'] as String? ?? '',
      descricao: d['descricao'] as String? ?? '',
      fotoUrl: (foto == null || foto.isEmpty) ? null : foto,
      encontrado: d['encontrado'] as bool? ?? false,
      autorUid: d['autorUid'] as String? ?? '',
      autorNome: d['autorNome'] as String? ?? '',
    );
  }

  /// dd/mm/aaaa
  static String formatarData(DateTime data) {
    String dois(int n) => n.toString().padLeft(2, '0');
    return '${dois(data.day)}/${dois(data.month)}/${data.year}';
  }

  String get dataFormatada => formatarData(dataDesaparecimento);

  int get diasDesaparecido {
    final hoje = DateTime.now();
    final a = DateTime(hoje.year, hoje.month, hoje.day);
    final b = DateTime(
      dataDesaparecimento.year,
      dataDesaparecimento.month,
      dataDesaparecimento.day,
    );
    return a.difference(b).inDays;
  }

  /// "hoje", "ontem" ou "há N dias".
  String get tempoDesaparecido {
    final dias = diasDesaparecido;
    if (dias <= 0) return 'hoje';
    if (dias == 1) return 'ontem';
    return 'há $dias dias';
  }
}