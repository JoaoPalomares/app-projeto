import 'package:flutter/material.dart';

import '../controller/solicitacoes_controller.dart';
import '../core/app_tema.dart';
import '../core/dependencias.dart';
import '../model/solicitacao_adocao_model.dart';
import 'componentes/chip_status_solicitacao.dart';

/// Aba da ONG: pedidos de adoção recebidos, em tempo real.
class SolicitacoesOngView extends StatefulWidget {
  const SolicitacoesOngView({super.key});

  @override
  State<SolicitacoesOngView> createState() => _SolicitacoesOngViewState();
}

class _SolicitacoesOngViewState extends State<SolicitacoesOngView> {
  final _controller = g<SolicitacoesController>();
  late Stream<List<Solicitacao>> _stream = _controller.daOng();

  void _tentarNovamente() => setState(() => _stream = _controller.daOng());

  Future<void> _responder(Solicitacao solicitacao, String status) async {
    final aprovar = status == Solicitacao.aprovada;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: Text(aprovar ? 'Aprovar solicitação?' : 'Recusar solicitação?'),
        content: Text(
          aprovar
              ? '${solicitacao.nome} será avisado(a) de que o pedido para '
                  'adotar ${solicitacao.animalNome} foi aprovado.'
              : 'O pedido de ${solicitacao.nome} para adotar '
                  '${solicitacao.animalNome} será recusado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contexto, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(contexto, true),
            child: Text(aprovar ? 'Aprovar' : 'Recusar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    final erro = await _controller.responder(solicitacao.id, status);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          erro ?? (aprovar ? 'Solicitação aprovada.' : 'Solicitação recusada.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitações')),
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
              icone: Icons.inbox_outlined,
              titulo: 'Nenhuma solicitação ainda',
              texto: 'Quando alguém pedir para adotar um dos seus animais, '
                  'o pedido aparece aqui na hora.',
            );
          }

          return ListView.separated(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              MediaQuery.paddingOf(context).bottom + 24,
            ),
            itemCount: lista.length,
            separatorBuilder: (context, indice) => const SizedBox(height: 12),
            itemBuilder: (context, indice) {
              final solicitacao = lista[indice];
              return _CartaoSolicitacao(
                solicitacao: solicitacao,
                onAprovar: () => _responder(solicitacao, Solicitacao.aprovada),
                onRecusar: () => _responder(solicitacao, Solicitacao.recusada),
              );
            },
          );
        },
      ),
    );
  }
}

class _CartaoSolicitacao extends StatelessWidget {
  const _CartaoSolicitacao({
    required this.solicitacao,
    required this.onAprovar,
    required this.onRecusar,
  });

  final Solicitacao solicitacao;
  final VoidCallback onAprovar;
  final VoidCallback onRecusar;

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
            'Enviada em ${s.dataFormatada}',
            style: const TextStyle(fontSize: 12, color: AppCores.textoSuave),
          ),
          const SizedBox(height: 12),
          _Linha(Icons.person_outline, s.nome),
          _Linha(Icons.phone_outlined, s.telefone),
          _Linha(Icons.mail_outline, s.email),
          _Linha(Icons.home_outlined, s.endereco),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 8),
              shape: const Border(),
              collapsedShape: const Border(),
              title: const Text(
                'Ver respostas da triagem',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppCores.verde,
                ),
              ),
              children: [
                _Resposta('Experiência com pets', s.experiencia),
                _Resposta('Tipo de moradia', s.moradia),
                _Resposta('Horas sozinho por dia', s.horasSozinho),
                _Resposta('Outros pets em casa', s.outrosPets),
                _Resposta('Por que quer adotar?', s.motivacao),
              ],
            ),
          ),
          if (s.status == Solicitacao.pendente) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onRecusar,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                      foregroundColor: AppCores.coral,
                      side: const BorderSide(color: AppCores.coral),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Recusar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onAprovar,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                      backgroundColor: AppCores.verde,
                    ),
                    child: const Text('Aprovar'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha(this.icone, this.texto);

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 18, color: AppCores.verde),
          const SizedBox(width: 8),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }
}

class _Resposta extends StatelessWidget {
  const _Resposta(this.pergunta, this.resposta);

  final String pergunta;
  final String resposta;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pergunta,
            style: const TextStyle(fontSize: 12, color: AppCores.textoSuave),
          ),
          Text(resposta, style: const TextStyle(height: 1.3)),
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