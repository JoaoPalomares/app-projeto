import 'package:flutter/material.dart';

import '../core/validadores.dart';
import '../model/animal_model.dart';
import '../model/solicitacao_adocao_model.dart';
import '../core/dependencias.dart';
import 'auth_controller.dart';
import 'solicitacoes_controller.dart';

/// Estado e regras do formulário de triagem de adoção.
class TriagemController extends ChangeNotifier {
  TriagemController(this.animal) {
    final usuario = g<AuthController>().usuarioLogado;
    nomeController.text = usuario?.nome ?? '';
    emailController.text = usuario?.email ?? '';
    telefoneController.text = usuario?.telefone ?? '';
  }

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
  
  String? _erro;
  String? get erro => _erro;

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

    /// Valida o formulário e grava a solicitação no Firestore.
  /// Retorna a solicitação criada, ou `null` se algum campo for inválido
  /// ou se o envio falhar (nesse caso, veja [erro]).
  Future<SolicitacaoAdocao?> enviar() async {
    _erro = null;

    final formularioValido = formKey.currentState?.validate() ?? false;
    if (!formularioValido) return null;

    _enviando = true;
    notifyListeners();

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

    final erro = await g<SolicitacoesController>().enviar(solicitacao);

    _enviando = false;
    _erro = erro;
    notifyListeners();
    return erro == null ? solicitacao : null;
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
