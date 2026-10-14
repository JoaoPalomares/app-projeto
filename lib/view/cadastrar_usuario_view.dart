import 'package:flutter/material.dart';

import '../controller/cadastrar_usuario_controller.dart';
import '../core/app_routes.dart';
import '../core/app_tema.dart';
import '../core/dependencias.dart';
import '../core/telefone_input_formatter.dart';
import 'componentes/componentes_auth.dart';

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
    super.dispose();
  }

  Future<void> _criarConta() async {
    FocusScope.of(context).unfocus();

    // Campos obrigatórios, e-mail válido e senhas iguais.
    if (!_formKey.currentState!.validate()) return;

    final criado = await _controller.cadastrar(
      nome: _nomeController.text,
      email: _emailController.text,
      telefone: _telefoneController.text,
      senha: _senhaController.text,
    );

    // Conta criada: o usuário já entra no app.
    if (criado && mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (_) => false,
      );
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
                      TextFormField(
                        controller: _nomeController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        validator: _controller.validarNome,
                        decoration: const InputDecoration(
                          labelText: 'Nome completo',
                          hintText: 'João Silva',
                          prefixIcon: Icon(Icons.person_outline),
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