import 'package:flutter/material.dart';

import '../controller/cadastrar_usuario_controller.dart';
import '../core/app_routes.dart';
import '../core/app_tema.dart';
import '../core/dependencias.dart';
import '../core/telefone_input_formatter.dart';
import 'componentes/componentes_auth.dart';
import '../model/usuario_model.dart';
import '../core/cnpj.dart';
import '../core/estados.dart';

class CadastrarUsuarioView extends StatefulWidget {
  const CadastrarUsuarioView({super.key});

  @override
  State<CadastrarUsuarioView> createState() => _CadastrarUsuarioViewState();
}

class _CadastrarUsuarioViewState extends State<CadastrarUsuarioView> {
  final _controller = g<CadastrarUsuarioController>();
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmacaoController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _descricaoController = TextEditingController();
  String? _estado;
  String _tipo = Usuario.tipoAdotante;

  @override
  void initState() {
    super.initState();
    _controller.reiniciar();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _confirmacaoController.dispose();
    _cidadeController.dispose();
    _cnpjController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _criarConta() async {
    FocusScope.of(context).unfocus();

    // Campos obrigatórios, e-mail válido e senhas iguais.
    if (!_formKey.currentState!.validate()) return;

    final ehOng = _tipo == Usuario.tipoOng;

    final criado = await _controller.cadastrar(
      nome: _nomeController.text,
      email: _emailController.text,
      telefone: _telefoneController.text,
      senha: _senhaController.text,
      tipo: _tipo,
      cidade: ehOng ? _cidadeController.text : '',
      estado: ehOng ? (_estado ?? '') : '',
      descricao: ehOng ? _descricaoController.text : '',
      cnpj: ehOng ? _cnpjController.text : '',
    );

    // Conta criada: o usuário já entra no app.
    if (criado && mounted) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, _) => Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(child: LogoMiaudote(largura: 180)),
                      const SizedBox(height: 16),
                      const Text(
                        'Criar Conta',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppCores.texto,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Junte-se à nossa comunidade de amor animal',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppCores.textoSuave),
                      ),
                      const SizedBox(height: 28),
                      SegmentedButton<String>(
                        showSelectedIcon: false,
                        style: SegmentedButton.styleFrom(
                          selectedBackgroundColor: AppCores.coral,
                          selectedForegroundColor: Colors.white,
                        ),
                        segments: const [
                          ButtonSegment(
                            value: Usuario.tipoAdotante,
                            label: Text('Quero adotar'),
                            icon: Icon(Icons.favorite_border),
                          ),
                          ButtonSegment(
                            value: Usuario.tipoOng,
                            label: Text('Sou uma ONG'),
                            icon: Icon(Icons.volunteer_activism_outlined),
                          ),
                        ],
                        selected: {_tipo},
                        onSelectionChanged: (escolha) =>
                            setState(() => _tipo = escolha.first),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nomeController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        validator: _controller.validarNome,
                        decoration: InputDecoration(
                          labelText: _tipo == Usuario.tipoOng
                              ? 'Nome da ONG'
                              : 'Nome completo',
                          hintText: _tipo == Usuario.tipoOng
                              ? 'ONG Amigos dos Bichos'
                              : 'João Silva',
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: _controller.validarEmail,
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          hintText: 'seu@email.com',
                          prefixIcon: Icon(Icons.mail_outline),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _telefoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [TelefoneInputFormatter()],
                        validator: _controller.validarTelefone,
                        decoration: const InputDecoration(
                          labelText: 'Telefone',
                          hintText: '(00) 00000-0000',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_tipo == Usuario.tipoOng) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _cidadeController,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: _controller.validarCidade,
                                decoration: const InputDecoration(
                                  labelText: 'Cidade',
                                  prefixIcon: Icon(
                                    Icons.location_city_outlined,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                initialValue: _estado,
                                isExpanded: true,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: _controller.validarEstado,
                                decoration: const InputDecoration(
                                  labelText: 'UF',
                                ),
                                items: [
                                  for (final uf in estadosBrasil)
                                    DropdownMenuItem(
                                      value: uf,
                                      child: Text(uf),
                                    ),
                                ],
                                onChanged: (valor) =>
                                    setState(() => _estado = valor),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _cnpjController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [CnpjInputFormatter()],
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: _controller.validarCnpj,
                          decoration: const InputDecoration(
                            labelText: 'CNPJ',
                            hintText: '00.000.000/0000-00',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descricaoController,
                          minLines: 3,
                          maxLines: 4,
                          maxLength: 300,
                          textCapitalization: TextCapitalization.sentences,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: _controller.validarDescricao,
                          decoration: const InputDecoration(
                            labelText: 'Sobre a ONG',
                            hintText: 'Conte brevemente o trabalho de vocês',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: _senhaController,
                        obscureText: _controller.ocultarSenha,
                        textInputAction: TextInputAction.next,
                        validator: _controller.validarSenha,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          helperText: 'Mínimo de 6 caracteres',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: _controller.ocultarSenha
                                ? 'Mostrar senha'
                                : 'Ocultar senha',
                            icon: Icon(
                              _controller.ocultarSenha
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: _controller.alternarVisibilidadeSenha,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmacaoController,
                        obscureText: _controller.ocultarConfirmacao,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _criarConta(),
                        validator: (valor) => _controller.validarConfirmacao(
                          valor,
                          _senhaController.text,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Confirmar senha',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: _controller.ocultarConfirmacao
                                ? 'Mostrar senha'
                                : 'Ocultar senha',
                            icon: Icon(
                              _controller.ocultarConfirmacao
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed:
                                _controller.alternarVisibilidadeConfirmacao,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_controller.erro != null) ...[
                        MensagemErro(_controller.erro!),
                        const SizedBox(height: 12),
                      ],
                      FilledButton(
                        onPressed: _controller.carregando ? null : _criarConta,
                        child: _controller.carregando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Criar minha conta'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Já tem uma conta?',
                            style: TextStyle(color: AppCores.textoSuave),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Faça login'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
