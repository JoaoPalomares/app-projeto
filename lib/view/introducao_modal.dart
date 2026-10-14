import 'package:flutter/material.dart';

import '../controller/introducao_controller.dart';
import '../core/app_tema.dart';
import 'componentes/componentes_auth.dart';

/// Abre o modal flutuante de introdução.
Future<void> mostrarIntroducao(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _IntroducaoDialog(),
  );
}

class _IntroducaoDialog extends StatefulWidget {
  const _IntroducaoDialog();

  @override
  State<_IntroducaoDialog> createState() => _IntroducaoDialogState();
}

class _IntroducaoDialogState extends State<_IntroducaoDialog> {
  // Controller local: só existe enquanto o modal estiver aberto.
  final _controller = IntroducaoController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _fechar() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LogoMiaudote(largura: 150),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 210,
                    child: PageView.builder(
                      controller: _controller.pageController,
                      onPageChanged: _controller.aoMudarPagina,
                      itemCount: IntroducaoController.passos.length,
                      itemBuilder: (_, i) =>
                          _Passo(IntroducaoController.passos[i]),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _Indicadores(
                    total: IntroducaoController.passos.length,
                    atual: _controller.passoAtual,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // Mantém o espaço para o botão "Próximo" não pular de lugar.
                      Visibility(
                        visible: !_controller.ultimoPasso,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: TextButton(
                          onPressed: _fechar,
                          child: const Text('Pular'),
                        ),
                      ),
                      const Spacer(),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(130, 48),
                        ),
                        onPressed: () {
                          if (_controller.avancar()) _fechar();
                        },
                        child: Text(
                          _controller.ultimoPasso ? 'Começar' : 'Próximo',
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Passo extends StatelessWidget {
  const _Passo(this.passo);

  final PassoIntroducao passo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: passo.cor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(passo.icone, size: 36, color: passo.cor),
        ),
        const SizedBox(height: 16),
        Text(
          passo.titulo,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppCores.texto,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          passo.texto,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppCores.textoSuave, height: 1.4),
        ),
      ],
    );
  }
}

class _Indicadores extends StatelessWidget {
  const _Indicadores({required this.total, required this.atual});

  final int total;
  final int atual;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final ativo = i == atual;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: ativo ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: ativo ? AppCores.coral : AppCores.borda,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}