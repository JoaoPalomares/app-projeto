import 'package:flutter/material.dart';

import '../controller/recuperar_senha_controller.dart';
import '../core/app_tema.dart';
import '../core/dependencias.dart';
import 'componentes/componentes_auth.dart';

class RecuperarSenhaView extends StatefulWidget {
  const RecuperarSenhaView({super.key});

  @override
  State<RecuperarSenhaView> createState() => _RecuperarSenhaViewState();
}

class _RecuperarSenhaViewState extends State<RecuperarSenhaView> {
  final _controller = g<RecuperarSenhaController>();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.reiniciar();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _solicitar() async {
    FocusScope.of(context).unfocus();

    // Campo vazio ou e-mail inválido: o Form mostra o erro.
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final enviado = await _controller.solicitar(email);
    if (!enviado || !mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.mark_email_read_outlined,
          color: AppCores.verde,
          size: 48,
        ),
        title: const Text('Verifique seu e-mail'),
        content: Text(
          'Enviamos as instruções para redefinir sua senha para $email.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Voltar ao login'),
          ),
        ],
      ),
    );

    if (mounted) Navigator.pop(context);
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
                        'Esqueceu a senha?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppCores.texto,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Informe o e-mail da sua conta e enviaremos as '
                        'instruções para redefinir a senha.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppCores.textoSuave,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _solicitar(),
                        validator: _controller.validarEmail,
                        decoration: const InputDecoration(
                          labelText: 'E-mail cadastrado',
                          hintText: 'seu@email.com',
                          prefixIcon: Icon(Icons.mail_outline),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_controller.erro != null) ...[
                        MensagemErro(_controller.erro!),
                        const SizedBox(height: 12),
                      ],
                      FilledButton(
                        onPressed: _controller.carregando ? null : _solicitar,
                        child: _controller.carregando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Enviar instruções'),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Voltar ao login'),
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