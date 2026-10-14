import 'animal_model.dart';

/// Dados enviados no formulário de triagem (RF05 - Processo de adoção).
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
}