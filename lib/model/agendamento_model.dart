class AgendamentoModel {
  const AgendamentoModel({
    required this.id,
    required this.nomePet,
    required this.servico,
    required this.dataHora,
    this.observacao = '',
  });

  final String id;
  final String nomePet;
  final String servico;
  final DateTime dataHora;
  final String observacao;
}