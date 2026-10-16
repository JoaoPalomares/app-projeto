class PetPerdidoModel {
  PetPerdidoModel({
    required this.id,
    required this.nome,
    required this.especie,
    required this.localVisto,
    required this.dataDesaparecimento,
    required this.contato,
    this.descricao = '',
    this.encontrado = false,
  });

  final String id;
  final String nome;
  final String especie;
  final String localVisto;
  final DateTime dataDesaparecimento;
  final String contato;
  final String descricao;
  bool encontrado;
}