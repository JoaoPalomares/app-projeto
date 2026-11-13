import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/adocao_controller.dart';
import '../controller/auth_controller.dart';
import '../controller/solicitacoes_controller.dart';
import '../core/app_tema.dart';
import '../core/dependencias.dart'; // onde está o `g`
import 'adocao_view.dart';
import 'agendamento_view.dart';
import 'introducao_modal.dart';
import 'meu_pet_view.dart';
import 'meus_animais_view.dart';
import 'perdidos_view.dart';
import 'perfil_view.dart';
import 'solicitacoes_ong_view.dart';

/// Posição da aba "Solicitações" na barra da ONG.
const _indiceSolicitacoes = 2;

/// Tela principal: guarda a barra de navegação inferior e as abas.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _indice = 0;

  final bool _ehOng = g<AuthController>().usuarioLogado?.ehOng ?? false;

  // Itens e abas mudam conforme o tipo de conta (ONG ou adotante).
  late final List<_ItemBarra> _itens = _ehOng ? _itensOng : _itensAdotante;

  // Criadas uma única vez. O IndexedStack mantém cada aba "viva", então a
  // busca e os filtros da Adoção não se perdem ao trocar de aba.
  late final List<Widget> _abas = _ehOng
      ? [
          _abaAdocao(),
          const MeusAnimaisView(),
          const SolicitacoesOngView(),
          const PerfilView(),
        ]
      : [
          _abaAdocao(),
          const MeuPetView(),
          const AgendarView(),
          const PerdidosView(),
          const PerfilView(),
        ];

  // Só para ONG: pedidos aguardando resposta (selo na barra e aviso).
  StreamSubscription<int>? _assinaturaPendentes;
  int _pendentes = 0;
  int? _ultimoTotal;

  Widget _abaAdocao() => ChangeNotifierProvider(
        create: (_) => AdocaoController(),
        child: const AdocaoView(),
      );

  @override
  void initState() {
    super.initState();

    if (_ehOng) {
      _assinaturaPendentes = g<SolicitacoesController>()
          .pendentesDaOng()
          .listen(_aoMudarPendentes, onError: (_) {});
    }

    // Espera o primeiro frame para ter um contexto pronto para o diálogo.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = g<AuthController>();
      if (!auth.introducaoVista) {
        auth.introducaoVista = true;
        mostrarIntroducao(context);
      }
    });
  }

  @override
  void dispose() {
    _assinaturaPendentes?.cancel();
    super.dispose();
  }

  void _aoMudarPendentes(int total) {
    final anterior = _ultimoTotal;
    _ultimoTotal = total;
    if (!mounted) return;

    setState(() => _pendentes = total);

    if (anterior == null) {
      if (total > 0) {
        _avisar(
          total == 1
              ? 'Você tem 1 solicitação pendente.'
              : 'Você tem $total solicitações pendentes.',
        );
      }
    } else if (total > anterior) {
      _avisar('Nova solicitação de adoção recebida!');
    }
  }

  /// Aviso dentro do app (equivale a uma notificação com o app aberto).
  void _avisar(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 96),
          content: Text(texto),
          action: SnackBarAction(
            label: 'Ver',
            onPressed: () => setState(() => _indice = _indiceSolicitacoes),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // O conteúdo passa por trás da barra, o que cria o efeito de vidro.
      extendBody: true,
      body: IndexedStack(index: _indice, children: _abas),
      bottomNavigationBar: _BarraFlutuante(
        itens: _itens,
        indice: _indice,
        selos: _ehOng ? {_indiceSolicitacoes: _pendentes} : const {},
        onSelecionar: (indice) => setState(() => _indice = indice),
      ),
    );
  }
}

class _ItemBarra {
  const _ItemBarra(this.icone, this.iconeAtivo, this.rotulo);

  final IconData icone;
  final IconData iconeAtivo;
  final String rotulo;
}

const _itensAdotante = [
  _ItemBarra(Icons.favorite_border, Icons.favorite, 'Adoção'),
  _ItemBarra(Icons.pets_outlined, Icons.pets, 'Meu Pet'),
  _ItemBarra(Icons.calendar_month_outlined, Icons.calendar_month, 'Agendar'),
  _ItemBarra(Icons.location_on_outlined, Icons.location_on, 'Perdidos'),
  _ItemBarra(Icons.person_outline, Icons.person, 'Perfil'),
];

const _itensOng = [
  _ItemBarra(Icons.favorite_border, Icons.favorite, 'Adoção'),
  _ItemBarra(
    Icons.volunteer_activism_outlined,
    Icons.volunteer_activism,
    'Meus animais',
  ),
  _ItemBarra(Icons.inbox_outlined, Icons.inbox, 'Solicitações'),
  _ItemBarra(Icons.person_outline, Icons.person, 'Perfil'),
];

/// Barra de navegação flutuante com efeito de vidro fosco.
class _BarraFlutuante extends StatelessWidget {
  const _BarraFlutuante({
    required this.itens,
    required this.indice,
    required this.selos,
    required this.onSelecionar,
  });

  final List<_ItemBarra> itens;
  final int indice;

  /// Contador exibido sobre o ícone de cada aba (posição -> quantidade).
  final Map<int, int> selos;
  final ValueChanged<int> onSelecionar;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.8),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        for (var i = 0; i < itens.length; i++)
                          Expanded(
                            child: _ItemBarraWidget(
                              item: itens[i],
                              selecionado: i == indice,
                              selo: selos[i] ?? 0,
                              onTap: () => onSelecionar(i),
                            ),
                          ),
                      ],
                    ),
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

class _ItemBarraWidget extends StatelessWidget {
  const _ItemBarraWidget({
    required this.item,
    required this.selecionado,
    required this.onTap,
    this.selo = 0,
  });

  final _ItemBarra item;
  final bool selecionado;
  final int selo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cor = selecionado ? AppCores.verde : AppCores.textoSuave;

    return Semantics(
      button: true,
      selected: selecionado,
      label: item.rotulo,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selecionado
                ? const Color.fromARGB(255, 224, 255, 255)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Badge(
                isLabelVisible: selo > 0,
                label: Text('$selo'),
                backgroundColor: AppCores.coral,
                child: Icon(
                  selecionado ? item.iconeAtivo : item.icone,
                  size: 22,
                  color: cor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.rotulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selecionado ? FontWeight.w600 : FontWeight.w400,
                  color: cor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}