import 'package:flutter/material.dart';

import '../core/validadores.dart';
import '../model/animal_model.dart';
import '../model/solicitacao_adocao_model.dart';

/// Estado e regras do formulário de triagem de adoção.
class TriagemController extends ChangeNotifier {
  TriagemController(this.animal);

  /// Animal que o usuário quer adotar (recebido pela rota).
  final Animal animal;

  static const List<String> opcoesExperiencia = [
    'Nunca tive pets',
    'Já tive pets',
    'Tenho pets atualmente',
  ];

  static const List<String> opcoesMoradia = [
    'Casa com quintal',
    'Casa sem quintal',
    'Apartamento',
  ];

  static const List<String> opcoesHorasSozinho = [
    'Menos de 4 horas',
    'De 4 a 8 horas',
    'Mais de 8 horas',
  ];

  static const List<String> opcoesOutrosPets = [
    'Não',
    'Sim, cachorro(s)',
    'Sim, gato(s)',
    'Sim, cachorro(s) e gato(s)',
  ];

  final formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();
  final enderecoController = TextEditingController();
  final motivacaoController = TextEditingController();

  // Valores escolhidos nas listas de seleção.
  String? experiencia;
  String? moradia;
  String? horasSozinho;
  String? outrosPets;

  bool _enviando = false;
  bool _descartado = false;

  bool get enviando => _enviando;

  // Validações dos campos de texto.
  String? validarNome(String? valor) =>
      Validadores.tamanhoMinimo(valor, 3, campo: 'O nome');

  String? validarEmail(String? valor) => Validadores.email(valor);

  String? validarTelefone(String? valor) => Validadores.telefone(valor);

  String? validarEndereco(String? valor) =>
      Validadores.obrigatorio(valor, campo: 'O endereço');

  String? validarMotivacao(String? valor) =>
      Validadores.tamanhoMinimo(valor, 10, campo: 'O motivo');

  /// Valida o formulário e "envia" a solicitação.
  /// Retorna a solicitação criada, ou `null` se algum campo for inválido.
  Future<SolicitacaoAdocao?> enviar() async {
    final formularioValido = formKey.currentState?.validate() ?? false;
    if (!formularioValido) return null;

    _enviando = true;
    notifyListeners();

    // Simula o envio para a API (nesta etapa nada é gravado em servidor).
    await Future.delayed(const Duration(milliseconds: 800));

    final solicitacao = SolicitacaoAdocao(
      animal: animal,
      nome: nomeController.text.trim(),
      email: emailController.text.trim(),
      telefone: telefoneController.text.trim(),
      endereco: enderecoController.text.trim(),
      experiencia: experiencia!,
      moradia: moradia!,
      horasSozinho: horasSozinho!,
      outrosPets: outrosPets!,
      motivacao: motivacaoController.text.trim(),
    );

    _enviando = false;
    notifyListeners();
    return solicitacao;
  }

  @override
  void notifyListeners() {
    // Evita erro caso o usuário saia da tela enquanto o envio ainda roda.
    if (!_descartado) super.notifyListeners();
  }

  @override
  void dispose() {
    _descartado = true;
    nomeController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    enderecoController.dispose();
    motivacaoController.dispose();
    super.dispose();
  }
}