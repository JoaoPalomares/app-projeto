import 'package:flutter/material.dart';

import '../model/agendamento_model.dart';

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

  final List<AgendamentoModel> _agendamentos = [];

  /// Ordenados do mais próximo para o mais distante.
  List<AgendamentoModel> get agendamentos {
    final copia = List<AgendamentoModel>.from(_agendamentos);
    copia.sort((a, b) => a.dataHora.compareTo(b.dataHora));
    return List.unmodifiable(copia);
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
  /// ou está ocupado por outro cliente (simulado para a demonstração).
  bool horarioIndisponivel(DateTime dia, TimeOfDay hora) {
    final inicio = combinar(dia, hora);
    if (!inicio.isAfter(DateTime.now())) return true;
    if (_ocupadoPorOutros(dia, hora)) return true;
    return _agendamentos.any((a) => a.dataHora.isAtSameMomentAs(inicio));
  }

  // Simula agendamentos de outros clientes (cerca de 1 horário em cada 4).
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