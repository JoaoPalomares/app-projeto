import 'package:flutter/material.dart';

import '../controller/auth_controller.dart';
import '../controller/perfil_controller.dart';
import '../core/app_routes.dart';
import '../core/app_tema.dart';
import '../core/dependencias.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  final _auth = g<AuthController>();
  final _controller = g<PerfilController>();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;

  // Reconstrói a tela quando o usuário ou o estado de "salvando" mudam.
  late final Listenable _ouvintes = Listenable.merge([_auth, _controller]);

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(
      text: _auth.usuarioLogado?.nome ?? '',
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    FocusScope.of(context).unfocus();

    // Nome vazio ou curto demais: o Form mostra o erro no campo.
    if (!_formKey.currentState!.validate()) return;

    await _controller.salvar(_nomeController.text);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil atualizado com sucesso!')),
    );
  }

  void _cancelar() {
    FocusScope.of(context).unfocus();
    // Limpa os erros e volta o campo para o nome que está salvo.
    _formKey.currentState?.reset();
    _nomeController.text = _auth.usuarioLogado?.nome ?? '';
  }

  void _sair() {
    _auth.logout();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu perfil')),
      body: ListenableBuilder(
        listenable: _ouvintes,
        builder: (context, _) {
          final usuario = _auth.usuarioLogado;

          // Regra de negócio: só usuários autenticados acessam o perfil.
          if (usuario == null) return const _SemSessao();

          final nome = usuario.nome.trim();
          final inicial = nome.isEmpty ? '?' : nome[0].toUpperCase();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 44,
                        backgroundColor: const Color(0xFFFBE3DC),
                        child: Text(
                          inicial,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppCores.coral,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      usuario.nome,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppCores.texto,
                      ),
                    ),
                    Text(
                      usuario.email,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppCores.textoSuave),
                    ),
                    const SizedBox(height: 28),
                    Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _nomeController,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _salvar(),
                            validator: _controller.validarNome,
                            decoration: const InputDecoration(
                              labelText: 'Nome',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // E-mail: somente visualização (não pode ser alterado).
                          TextFormField(
                            initialValue: usuario.email,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'E-mail',
                              helperText:
                                  'O e-mail de acesso não pode ser alterado.',
                              prefixIcon: Icon(Icons.mail_outline),
                              suffixIcon: Icon(Icons.lock_outline),
                              fillColor: Color(0xFFF3F4F6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _controller.salvando ? null : _salvar,
                      child: _controller.salvando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Salvar alterações'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _controller.salvando ? null : _cancelar,
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
                    const SizedBox(height: 16),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.info_outline),
                      title: const Text('Sobre o Miaudote'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.sobre,
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.logout, color: Colors.redAccent),
                      title: const Text(
                        'Sair da conta',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                      onTap: _sair,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Mostrada se alguém abrir o perfil sem ter feito login.
class _SemSessao extends StatelessWidget {
  const _SemSessao();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: AppCores.borda),
            const SizedBox(height: 12),
            const Text(
              'Entre na sua conta para ver o perfil.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (_) => false,
              ),
              child: const Text('Ir para o login'),
            ),
          ],
        ),
      ),
    );
  }
}