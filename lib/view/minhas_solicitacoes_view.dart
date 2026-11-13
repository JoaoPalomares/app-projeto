import 'package:flutter/material.dart';

import '../controller/solicitacoes_controller.dart';
import '../core/app_tema.dart';
import '../core/dependencias.dart';
import '../model/solicitacao_adocao_model.dart';
import 'componentes/chip_status_solicitacao.dart';

/// Pedidos de adoção do adotante. O status muda sozinho quando a ONG responde.
class MinhasSolicitacoesView extends StatefulWidget {
  const MinhasSolicitacoesView({super.key});

  @override
  State<MinhasSolicitacoesView> createState() => _MinhasSolicitacoesViewState();
}

class _MinhasSolicitacoesViewState extends State<MinhasSolicitacoesView> {
  final _controller = g<SolicitacoesController>();
  late Stream<List<Solicitacao>> _stream = _controller.doAdotante();

  void _tentarNovamente() => setState(() => _stream = _controller.doAdotante());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas solicitações')),
      body: StreamBuilder<List<Solicitacao>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _MensagemCentral(
              icone: Icons.cloud_off,
              titulo: 'Não foi possível carregar',
              texto: 'Verifique sua conexão e tente de novo.',
              onTentar: _tentarNovamente,
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final lista = snapshot.data!;
          if (lista.isEmpty) {
            return const _MensagemCentral(
              icone: Icons.assignment_outlined,
              titulo: 'Nenhuma solicitação enviada',
              texto: 'Escolha um pet no Portal de Adoção e toque em '
                  '"Quero adotar".',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lista.length,
            separatorBuilder: (context, indice) => const SizedBox(height: 12),
            itemBuilder: (context, indice) =>
                _CartaoMinhaSolicitacao(solicitacao: lista[indice]),
          );
        },
      ),
    );
  }
}

class _CartaoMinhaSolicitacao extends StatelessWidget {
  const _CartaoMinhaSolicitacao({required this.solicitacao});

  final Solicitacao solicitacao;

  String get _mensagem => switch (solicitacao.status) {
        Solicitacao.aprovada => 'Parabéns! A ONG aprovou o seu pedido e vai '
            'entrar em contato pelo telefone ou e-mail informado.',
        Solicitacao.recusada => 'Desta vez a ONG não pôde seguir com esta '
            'adoção. Veja outros pets no Portal de Adoção.',
        _ => 'Aguardando a análise da ONG.',
      };

  @override
  Widget build(BuildContext context) {
    final s = solicitacao;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppCores.borda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Adotar ${s.animalNome}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppCores.texto,
                  ),
                ),
              ),
              ChipStatusSolicitacao(status: s.status),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'ONG: ${s.ongNome} • enviada em ${s.dataFormatada}',
            style: const TextStyle(fontSize: 12, color: AppCores.textoSuave),
          ),
          const SizedBox(height: 10),
          Text(_mensagem, style: const TextStyle(height: 1.4)),
        ],
      ),
    );
  }
}

class _MensagemCentral extends StatelessWidget {
  const _MensagemCentral({
    required this.icone,
    required this.titulo,
    required this.texto,
    this.onTentar,
  });

  final IconData icone;
  final String titulo;
  final String texto;
  final VoidCallback? onTentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 64, color: AppCores.borda),
            const SizedBox(height: 12),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppCores.texto,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppCores.textoSuave),
            ),
            if (onTentar != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onTentar,
                child: const Text('Tentar novamente'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}