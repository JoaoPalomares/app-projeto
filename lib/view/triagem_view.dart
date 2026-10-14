import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../controller/triagem_controller.dart';
import '../core/app_tema.dart';
import '../model/animal_model.dart';

class TriagemView extends StatelessWidget {
  const TriagemView({super.key});

  Future<void> _enviar(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final solicitacao = await context.read<TriagemController>().enviar();
    if (solicitacao == null || !context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.check_circle_outline,
          color: AppCores.verde,
          size: 48,
        ),
        title: const Text('Solicitação enviada!'),
        content: Text(
          'A ${solicitacao.animal.ong} vai analisar suas respostas sobre '
          '${solicitacao.animal.nome} e entrará em contato pelo e-mail ou '
          'telefone informado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Voltar ao portal'),
          ),
        ],
      ),
    );

    // Fecha a triagem e volta para a lista de adoção.
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TriagemController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Solicitação de adoção')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: controller.formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ResumoAnimal(animal: controller.animal),
                    const SizedBox(height: 20),
                    const Text(
                      'Para garantir o bem-estar do animal, precisamos '
                      'conhecer um pouco mais sobre você e sua casa.',
                      style: TextStyle(
                        color: AppCores.textoSuave,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _TituloSecao('Seus dados'),
                    TextFormField(
                      controller: controller.nomeController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      validator: controller.validarNome,
                      decoration: const InputDecoration(
                        labelText: 'Nome completo',
                        hintText: 'Seu nome',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: controller.validarEmail,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        hintText: 'seu@email.com',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: controller.telefoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: controller.validarTelefone,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9()\-\s+]'),
                        ),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Telefone',
                        hintText: '(00) 00000-0000',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: controller.enderecoController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      validator: controller.validarEndereco,
                      decoration: const InputDecoration(
                        labelText: 'Endereço completo',
                        hintText: 'Rua, número, bairro',
                      ),
                    ),
                    const SizedBox(height: 28),
                    const _TituloSecao('Sobre você e sua casa'),
                    _CampoSelecao(
                      rotulo: 'Você tem experiência com pets?',
                      opcoes: TriagemController.opcoesExperiencia,
                      onChanged: (valor) => controller.experiencia = valor,
                    ),
                    const SizedBox(height: 16),
                    _CampoSelecao(
                      rotulo: 'Tipo de moradia',
                      opcoes: TriagemController.opcoesMoradia,
                      onChanged: (valor) => controller.moradia = valor,
                    ),
                    const SizedBox(height: 16),
                    _CampoSelecao(
                      rotulo: 'Quantas horas por dia o pet ficará sozinho?',
                      opcoes: TriagemController.opcoesHorasSozinho,
                      onChanged: (valor) => controller.horasSozinho = valor,
                    ),
                    const SizedBox(height: 16),
                    _CampoSelecao(
                      rotulo: 'Você tem outros pets em casa?',
                      opcoes: TriagemController.opcoesOutrosPets,
                      onChanged: (valor) => controller.outrosPets = valor,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: controller.motivacaoController,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      minLines: 4,
                      maxLines: 6,
                      validator: controller.validarMotivacao,
                      decoration: const InputDecoration(
                        labelText: 'Por que você quer adotar?',
                        hintText: 'Conte-nos suas motivações...',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 28),
                    FilledButton(
                      onPressed:
                          controller.enviando ? null : () => _enviar(context),
                      child: controller.enviando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Enviar solicitação'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: controller.enviando
                          ? null
                          : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        foregroundColor: AppCores.verde,
                        side: const BorderSide(color: AppCores.verde),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Cartão no topo mostrando qual animal está sendo solicitado.
class _ResumoAnimal extends StatelessWidget {
  const _ResumoAnimal({required this.animal});

  final Animal animal;

  @override
  Widget build(BuildContext context) {
    final gato = animal.especie == Especie.gato;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppCores.borda),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor:
                gato ? const Color(0xFFD9F2EF) : const Color(0xFFFBE3DC),
            child: Icon(
              Icons.pets,
              color: gato ? AppCores.verde : AppCores.coral,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adotar ${animal.nome}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppCores.texto,
                  ),
                ),
                Text(
                  '${animal.raca} • ${animal.idadeFormatada}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppCores.textoSuave,
                  ),
                ),
                Text(
                  '${animal.cidade} • ${animal.ong}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppCores.textoSuave,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TituloSecao extends StatelessWidget {
  const _TituloSecao(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppCores.texto,
        ),
      ),
    );
  }
}

/// Lista de seleção obrigatória (o valor escolhido vai para o controller).
class _CampoSelecao extends StatelessWidget {
  const _CampoSelecao({
    required this.rotulo,
    required this.opcoes,
    required this.onChanged,
  });

  final String rotulo;
  final List<String> opcoes;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: InputDecoration(labelText: rotulo),
      hint: const Text('Selecione...'),
      items: [
        for (final opcao in opcoes)
          DropdownMenuItem(value: opcao, child: Text(opcao)),
      ],
      onChanged: onChanged,
      validator: (valor) => valor == null ? 'Selecione uma opção.' : null,
    );
  }
}