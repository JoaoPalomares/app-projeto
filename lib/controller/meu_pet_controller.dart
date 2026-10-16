import 'package:flutter/material.dart';

import '../core/validadores.dart';
import '../model/pet_model.dart';

/// Estado e regras da funcionalidade "Meu Pet" (cadastrar e listar pets).
class MeuPetController extends ChangeNotifier {
  MeuPetController() {
    // Dado mock para a demonstração não abrir vazia.
    _pets.add(
      const PetModel(
        id: 'mock-1',
        nome: 'Mel',
        especie: 'Cachorro',
        idadeAnos: 3,
        raca: 'Vira-lata caramelo',
      ),
    );
  }

  static const List<String> especies = ['Cachorro', 'Gato', 'Outro'];

  final List<PetModel> _pets = [];

  List<PetModel> get pets => List.unmodifiable(_pets);

  String? validarNome(String? valor) =>
      Validadores.tamanhoMinimo(valor, 2, campo: 'O nome do pet');

  String? validarEspecie(String? valor) {
    if (valor == null || valor.isEmpty) return 'Escolha a espécie.';
    return null;
  }

  String? validarIdade(String? valor) {
    final vazio = Validadores.obrigatorio(
      valor,
      campo: 'A idade',
      feminino: true,
    );
    if (vazio != null) return vazio;

    final idade = int.tryParse(valor!.trim());
    if (idade == null || idade < 0 || idade > 40) {
      return 'Informe a idade em anos (0 a 40).';
    }
    return null;
  }

  void adicionar({
    required String nome,
    required String especie,
    required int idadeAnos,
    String raca = '',
    String observacao = '',
  }) {
    _pets.add(
      PetModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        nome: nome.trim(),
        especie: especie,
        idadeAnos: idadeAnos,
        raca: raca.trim(),
        observacao: observacao.trim(),
      ),
    );
    notifyListeners();
  }

  void remover(String id) {
    _pets.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}