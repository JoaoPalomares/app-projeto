import 'package:flutter/material.dart';

import '../model/agendamento_model.dart';

class AgendarController extends ChangeNotifier {
  static const List<String> servicos = [
    'Consulta veterinária',
    'Vacinação',
    'Banho e tosa',
    'Castração',
  ];

  final List<AgendamentoModel> _agendamentos = [];

  /// Ordenados do mais próximo para o mais distante.
  List<AgendamentoModel> get agendamentos {
    final copia = List<AgendamentoModel>.from(_agendamentos);
    copia.sort((a, b) => a.dataHora.compareTo(b.dataHora));
    return List.unmodifiable(copia);
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

  void agendar({
    required String nomePet,
    required String servico,
    required DateTime data,
    required TimeOfDay hora,
    String observacao = '',
  }) {
    _agendamentos.add(
      AgendamentoModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        nomePet: nomePet.trim(),
        servico: servico,
        dataHora: combinar(data, hora),
        observacao: observacao.trim(),
      ),
    );
    notifyListeners();
  }

  void cancelar(String id) {
    _agendamentos.removeWhere((a) => a.id == id);
    notifyListeners();
  }
}