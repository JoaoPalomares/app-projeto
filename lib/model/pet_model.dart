class PetModel {
  const PetModel({
    required this.id,
    required this.nome,
    required this.especie,
    required this.idadeAnos,
    this.raca = '',
    this.observacao = '',
  });

  final String id;
  final String nome;
  final String especie;
  final int idadeAnos;
  final String raca;
  final String observacao;
}