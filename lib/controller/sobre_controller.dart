import 'package:flutter/material.dart';

/// Informações exibidas na tela "Sobre" (RF004).
class SobreController extends ChangeNotifier {
  final String nomeApp = 'Miaudote';
  final String versao = '1.0.0';

  final String objetivo =
      'Reunir, em um só lugar, a adoção responsável de animais, o '
      'acompanhamento da saúde dos pets, a localização de animais perdidos '
      'e o agendamento de serviços veterinários e de cuidados.';

  // Remova o Eduardo se o app for entregue individualmente.
  final List<String> integrantes = const [
    'Eduardo Cruz Junior',
    'João Pedro Palomares',
  ];

  final String disciplina = 'Dispositivos Móveis';
  final String curso = 'Análise e Desenvolvimento de Sistemas';
  final String instituicao = 'FATEC Ribeirão Preto';
  final String professor = 'Plotze';
}