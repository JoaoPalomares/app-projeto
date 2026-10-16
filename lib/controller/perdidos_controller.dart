import 'package:flutter/material.dart';

import '../core/validadores.dart';
import '../model/pet_perdido_model.dart';

/// Estado e regras da funcionalidade "Pets Perdidos".
class PerdidosController extends ChangeNotifier {
  PerdidosController() {
    // Dados mock para a demonstração não abrir vazia.
    final hoje = DateTime.now();
    _lista.addAll([
      PetPerdidoModel(
        id: 'mock-1',
        nome: 'Thor',
        especie: 'Cachorro',
        localVisto: 'Praça XV de Novembro, Centro',
        dataDesaparecimento: hoje.subtract(const Duration(days: 2)),
        contato: '(16) 99999-1111',
        descricao: 'Porte médio, pelagem preta, coleira vermelha.',
      ),
      PetPerdidoModel(
        id: 'mock-2',
        nome: 'Luna',
        especie: 'Gato',
        localVisto: 'Av. Costábile Romano',
        dataDesaparecimento: hoje.subtract(const Duration(days: 5)),
        contato: '(16) 98888-2222',
        descricao: 'Gata cinza de olhos verdes, muito dócil.',
      ),
    ]);
  }

  static const List<String> especies = ['Cachorro', 'Gato', 'Outro'];

  final List<PetPerdidoModel> _lista = [];

  /// Perdidos primeiro; dentro de cada grupo, os mais recentes antes.
  List<PetPerdidoModel> get pets {
    final copia = List<PetPerdidoModel>.from(_lista);
    copia.sort((a, b) {
      if (a.encontrado != b.encontrado) return a.encontrado ? 1 : -1;
      return b.dataDesaparecimento.compareTo(a.dataDesaparecimento);
    });
    return List.unmodifiable(copia);
  }

  String? validarNome(String? valor) =>
      Validadores.tamanhoMinimo(valor, 2, campo: 'O nome do pet');

  String? validarEspecie(String? valor) {
    if (valor == null || valor.isEmpty) return 'Escolha a espécie.';
    return null;
  }

  String? validarLocal(String? valor) =>
      Validadores.tamanhoMinimo(valor, 5, campo: 'O local');

  String? validarContato(String? valor) => Validadores.telefone(valor);

  String? validarData(DateTime? data) {
    if (data == null) return 'Informe a data do desaparecimento.';
    if (data.isAfter(DateTime.now())) return 'A data não pode ser futura.';
    return null;
  }

  void reportar({
    required String nome,
    required String especie,
    required String localVisto,
    required DateTime data,
    required String contato,
    String descricao = '',
  }) {
    _lista.add(
      PetPerdidoModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        nome: nome.trim(),
        especie: especie,
        localVisto: localVisto.trim(),
        dataDesaparecimento: data,
        contato: contato.trim(),
        descricao: descricao.trim(),
      ),
    );
    notifyListeners();
  }

  void alternarEncontrado(String id) {
    final pet = _lista.firstWhere((p) => p.id == id);
    pet.encontrado = !pet.encontrado;
    notifyListeners();
  }
}