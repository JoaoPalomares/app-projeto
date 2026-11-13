import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controller/auth_controller.dart';
import '../controller/perdidos_controller.dart';
import '../core/app_tema.dart';
import '../core/dependencias.dart';
import '../core/telefone_input_formatter.dart';
import '../model/animal_model.dart';
import '../model/pet_perdido_model.dart';

/// Pets perdidos: a comunidade anuncia e a ONG ajuda a encontrar.
class PerdidosView extends StatefulWidget {
  const PerdidosView({super.key});

  @override
  State<PerdidosView> createState() => _PerdidosViewState();
}

class _PerdidosViewState extends State<PerdidosView> {
  final _controller = g<PerdidosController>();
  late Stream<List<PetPerdidoModel>> _stream = _controller.todos();

  @override
  void initState() {
    super.initState();
    _controller.reiniciar();
  }

  void _tentarNovamente() => setState(() => _stream = _controller.todos());

  Future<void> _abrirAnuncio() async {
    final mensagens = ScaffoldMessenger.of(context);

    final publicou = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const _FormularioAnuncio(),
    );

    if (publicou == true) {
      mensagens.showSnackBar(
        const SnackBar(
          content: Text('Anúncio publicado! A comunidade já pode ajudar.'),
        ),
      );
    }
  }

  void _abrirDetalhes(PetPerdidoModel pet) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _DetalhesPet(pet: pet),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pets Perdidos')),
      // RF004: lista em tempo real, com erro e nova tentativa.
      body: StreamBuilder<List<PetPerdidoModel>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _ErroCarregar(onTentar: _tentarNovamente);
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final todos = snapshot.data!;
          final perdidos = todos.where((pet) => !pet.encontrado).length;
          final encontrados = todos.length - perdidos;

          return ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              final lista = _controller.filtrar(todos);

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _Banner(
                      ehOng: _controller.ehOng,
                      perdidos: perdidos,
                      encontrados: encontrados,
                      onAnunciar: _controller.ehOng ? null : _abrirAnuncio,
                    ),
                  ),
                  SliverToBoxAdapter(child: _Busca(controller: _controller)),
                  if (lista.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _SemResultados(
                        vazioGeral: todos.isEmpty,
                        onLimpar: _controller.limpar,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        8,
                        16,
                        MediaQuery.paddingOf(context).bottom + 96,
                      ),
                      sliver: SliverGrid.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 240,
                              mainAxisExtent: 290,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                            ),
                        itemCount: lista.length,
                        itemBuilder: (context, indice) {
                          final pet = lista[indice];
                          return _CartaoPet(
                            pet: pet,
                            onTap: () => _abrirDetalhes(pet),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Topo: banner, busca e filtros
// ---------------------------------------------------------------------------

class _Banner extends StatelessWidget {
  const _Banner({
    required this.ehOng,
    required this.perdidos,
    required this.encontrados,
    this.onAnunciar,
  });

  final bool ehOng;
  final int perdidos;
  final int encontrados;

  /// Nulo para a ONG, que só acompanha os anúncios.
  final VoidCallback? onAnunciar;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppCores.coral, Color(0xFFF2A58E)],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ehOng ? 'Ajude a trazê-los de volta' : 'Perdeu o seu pet?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ehOng
                      ? 'Acompanhe os anúncios e marque quando um pet for '
                            'encontrado.'
                      : 'Anuncie aqui e a comunidade ajuda a procurar.',
                  style: const TextStyle(color: Colors.white, height: 1.3),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _Estatistica(numero: perdidos, rotulo: 'perdidos'),
                    const SizedBox(width: 24),
                    _Estatistica(numero: encontrados, rotulo: 'encontrados'),
                  ],
                ),
                if (onAnunciar != null) ...[
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: onAnunciar,
                    icon: const Icon(Icons.campaign_outlined),
                    label: const Text('Anunciar pet perdido'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppCores.coral,
                      minimumSize: const Size.fromHeight(44),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.travel_explore,
            size: 64,
            color: Colors.white.withValues(alpha: 0.35),
          ),
        ],
      ),
    );
  }
}

class _Estatistica extends StatelessWidget {
  const _Estatistica({required this.numero, required this.rotulo});

  final int numero;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$numero',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(rotulo, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}

class _Busca extends StatelessWidget {
  const _Busca({required this.controller});

  final PerdidosController controller;

  static const _rotulos = {
    FiltroPerdidos.todos: 'Todos',
    FiltroPerdidos.perdidos: 'Perdidos',
    FiltroPerdidos.encontrados: 'Encontrados',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller.buscaController,
            onChanged: controller.buscar,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: 'Buscar por nome, espécie ou local',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final entrada in _rotulos.entries)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _ChipFiltro(
                    rotulo: entrada.value,
                    selecionado: controller.filtro == entrada.key,
                    onTap: () => controller.definirFiltro(entrada.key),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChipFiltro extends StatelessWidget {
  const _ChipFiltro({
    required this.rotulo,
    required this.selecionado,
    required this.onTap,
  });

  final String rotulo;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selecionado ? AppCores.verde : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selecionado ? AppCores.verde : AppCores.borda,
          ),
        ),
        child: Text(
          rotulo,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selecionado ? Colors.white : AppCores.texto,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Cards
// ---------------------------------------------------------------------------

class _CartaoPet extends StatelessWidget {
  const _CartaoPet({required this.pet, required this.onTap});

  final PetPerdidoModel pet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppCores.borda),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _FotoPet(pet: pet),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _SeloStatus(encontrado: pet.encontrado),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(10, 18, 10, 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                      child: Text(
                        pet.encontrado
                            ? 'Voltou para casa'
                            : 'Sumiu ${pet.tempoDesaparecido}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    pet.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppCores.texto,
                    ),
                  ),
                  Text(
                    pet.especie.rotulo,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppCores.textoSuave,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppCores.textoSuave,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          pet.localVisto,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppCores.textoSuave,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Foto do anúncio; sem link (ou com link quebrado) mostra um ícone.
class _FotoPet extends StatelessWidget {
  const _FotoPet({required this.pet, this.tamanhoIcone = 48});

  final PetPerdidoModel pet;
  final double tamanhoIcone;

  @override
  Widget build(BuildContext context) {
    final gato = pet.especie == Especie.gato;

    final icone = ColoredBox(
      color: gato ? const Color(0xFFD9F2EF) : const Color(0xFFFBE3DC),
      child: Center(
        child: Icon(
          Icons.pets,
          size: tamanhoIcone,
          color: gato ? AppCores.verde : AppCores.coral,
        ),
      ),
    );

    final url = pet.fotoUrl;
    if (url == null || url.isEmpty) return icone;

    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      semanticLabel: 'Foto de ${pet.nome}',
      errorBuilder: (context, error, stackTrace) => icone,
    );
  }
}

class _SeloStatus extends StatelessWidget {
  const _SeloStatus({required this.encontrado});

  final bool encontrado;

  @override
  Widget build(BuildContext context) {
    final fundo = encontrado
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFFEE2E2);
    final cor = encontrado ? const Color(0xFF166534) : const Color(0xFF991B1B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        encontrado ? 'ENCONTRADO' : 'PERDIDO',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          color: cor,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Detalhes do anúncio
// ---------------------------------------------------------------------------

class _DetalhesPet extends StatelessWidget {
  const _DetalhesPet({required this.pet});

  final PetPerdidoModel pet;

  Future<void> _alternar(BuildContext context) async {
    final mensagens = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);

    final erro = await g<PerdidosController>().alternarEncontrado(pet);

    navegador.pop();
    mensagens.showSnackBar(
      SnackBar(
        content: Text(
          erro ??
              (pet.encontrado
                  ? 'Busca reaberta.'
                  : 'Que ótima notícia! Marcado como encontrado.'),
        ),
      ),
    );
  }

  Future<void> _excluir(BuildContext context) async {
    final mensagens = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('Excluir anúncio?'),
        content: Text('O anúncio de ${pet.nome} sairá da lista.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contexto, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(contexto, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    final erro = await g<PerdidosController>().excluir(pet.id);

    navegador.pop();
    mensagens.showSnackBar(
      SnackBar(content: Text(erro ?? 'Anúncio excluído.')),
    );
  }

  Future<void> _copiarContato(BuildContext context) async {
    final mensagens = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: pet.contato));
    mensagens.showSnackBar(const SnackBar(content: Text('Contato copiado.')));
  }

  @override
  Widget build(BuildContext context) {
    final controller = g<PerdidosController>();
    final podeMarcar = controller.podeMarcar(pet);
    final ehAutor = controller.ehAutor(pet);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 200,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _FotoPet(pet: pet, tamanhoIcone: 72),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: _SeloStatus(encontrado: pet.encontrado),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              pet.nome,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppCores.texto,
              ),
            ),
            Text(
              pet.especie.rotulo,
              style: const TextStyle(color: AppCores.textoSuave),
            ),
            const SizedBox(height: 12),
            _LinhaInfo(
              icone: Icons.location_on_outlined,
              texto: 'Visto pela última vez em ${pet.localVisto}',
            ),
            _LinhaInfo(
              icone: Icons.event_outlined,
              texto:
                  'Desapareceu em ${pet.dataFormatada} '
                  '(${pet.tempoDesaparecido})',
            ),
            _LinhaInfo(
              icone: Icons.person_outline,
              texto: 'Anunciado por ${pet.autorNome}',
            ),
            _LinhaInfo(
              icone: Icons.phone_outlined,
              texto: pet.contato,
              acao: IconButton(
                tooltip: 'Copiar contato',
                visualDensity: VisualDensity.compact,
                onPressed: () => _copiarContato(context),
                icon: const Icon(Icons.copy, size: 18, color: AppCores.verde),
              ),
            ),
            if (pet.descricao.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(pet.descricao, style: const TextStyle(height: 1.4)),
            ],
            const SizedBox(height: 20),
            if (podeMarcar)
              pet.encontrado
                  ? OutlinedButton.icon(
                      onPressed: () => _alternar(context),
                      icon: const Icon(Icons.undo),
                      label: const Text('Reabrir busca'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        foregroundColor: AppCores.verde,
                        side: const BorderSide(color: AppCores.verde),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  : FilledButton.icon(
                      onPressed: () => _alternar(context),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Marcar como encontrado'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppCores.verde,
                      ),
                    )
            else if (!pet.encontrado)
              FilledButton.icon(
                onPressed: () => _copiarContato(context),
                icon: const Icon(Icons.copy),
                label: const Text('Copiar contato do dono'),
              ),
            if (ehAutor) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => _excluir(context),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Excluir anúncio'),
                style: TextButton.styleFrom(foregroundColor: AppCores.coral),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LinhaInfo extends StatelessWidget {
  const _LinhaInfo({required this.icone, required this.texto, this.acao});

  final IconData icone;
  final String texto;
  final Widget? acao;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icone, size: 18, color: AppCores.verde),
          const SizedBox(width: 8),
          Expanded(child: Text(texto)),
          ?acao,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Formulário de anúncio
// ---------------------------------------------------------------------------

class _FormularioAnuncio extends StatefulWidget {
  const _FormularioAnuncio();

  @override
  State<_FormularioAnuncio> createState() => _FormularioAnuncioState();
}

class _FormularioAnuncioState extends State<_FormularioAnuncio> {
  final _controller = g<PerdidosController>();
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _local = TextEditingController();
  final _dataController = TextEditingController();
  final _contato = TextEditingController();
  final _descricao = TextEditingController();
  final _foto = TextEditingController();

  Especie _especie = Especie.cachorro;
  DateTime? _data;
  String? _erro;

  @override
  void initState() {
    super.initState();
    // O telefone da conta já vem preenchido (dá para alterar).
    _contato.text = g<AuthController>().usuarioLogado?.telefone ?? '';
  }

  @override
  void dispose() {
    _nome.dispose();
    _local.dispose();
    _dataController.dispose();
    _contato.dispose();
    _descricao.dispose();
    _foto.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final hoje = DateTime.now();

    final escolhida = await showDatePicker(
      context: context,
      initialDate: _data ?? hoje,
      firstDate: hoje.subtract(const Duration(days: 365)),
      lastDate: hoje,
      helpText: 'Quando ele desapareceu?',
    );

    if (escolhida != null) {
      setState(() {
        _data = escolhida;
        _dataController.text = PetPerdidoModel.formatarData(escolhida);
      });
    }
  }

  Future<void> _publicar() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _erro = null);

    final erro = await _controller.anunciar(
      nome: _nome.text,
      especie: _especie,
      local: _local.text,
      data: _data!,
      contato: _contato.text,
      descricao: _descricao.text,
      fotoUrl: _foto.text,
    );

    if (!mounted) return;
    if (erro == null) {
      Navigator.pop(context, true);
    } else {
      setState(() => _erro = erro);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Anunciar pet perdido',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppCores.texto,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Quanto mais detalhes, mais fácil de a comunidade ajudar.',
                style: TextStyle(color: AppCores.textoSuave),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nome,
                textCapitalization: TextCapitalization.words,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: _controller.validarNome,
                decoration: const InputDecoration(
                  labelText: 'Nome do pet',
                  prefixIcon: Icon(Icons.pets),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Especie>(
                initialValue: _especie,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Espécie',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: [
                  for (final item in Especie.values)
                    DropdownMenuItem(value: item, child: Text(item.rotulo)),
                ],
                onChanged: (valor) =>
                    setState(() => _especie = valor ?? _especie),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _local,
                textCapitalization: TextCapitalization.sentences,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: _controller.validarLocal,
                decoration: const InputDecoration(
                  labelText: 'Onde foi visto pela última vez',
                  hintText: 'Rua, bairro ou ponto de referência',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dataController,
                readOnly: true,
                onTap: _escolherData,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (_) =>
                    _data == null ? 'Informe a data do desaparecimento.' : null,
                decoration: const InputDecoration(
                  labelText: 'Data do desaparecimento',
                  prefixIcon: Icon(Icons.event_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contato,
                keyboardType: TextInputType.phone,
                inputFormatters: [TelefoneInputFormatter()],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: _controller.validarContato,
                decoration: const InputDecoration(
                  labelText: 'Telefone para contato',
                  hintText: '(00) 00000-0000',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricao,
                minLines: 3,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  hintText: 'Cor, coleira, comportamento...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _foto,
                keyboardType: TextInputType.url,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: _controller.validarLink,
                decoration: const InputDecoration(
                  labelText: 'Link da foto (opcional)',
                  hintText: 'https://...',
                  helperText:
                      'Precisa ser o link direto da imagem. '
                      'Se a prévia não aparecer, o link não serve.',
                  helperMaxLines: 2,
                  prefixIcon: Icon(Icons.image_outlined),
                ),
              ),
              ListenableBuilder(
                listenable: _foto,
                builder: (context, _) {
                  final link = _foto.text.trim();
                  if (link.isEmpty || _controller.validarLink(link) != null) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 150,
                        child: Image.network(
                          link,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              const ColoredBox(
                                color: AppCores.fundo,
                                child: Center(
                                  child: Text(
                                    'Não foi possível carregar a imagem.',
                                    style: TextStyle(
                                      color: AppCores.textoSuave,
                                    ),
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (_erro != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppCores.coral.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _erro!,
                    style: const TextStyle(color: AppCores.coral),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ListenableBuilder(
                listenable: _controller,
                builder: (context, _) => FilledButton(
                  onPressed: _controller.salvando ? null : _publicar,
                  child: _controller.salvando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Publicar anúncio'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Estados vazios e erro
// ---------------------------------------------------------------------------

class _SemResultados extends StatelessWidget {
  const _SemResultados({required this.vazioGeral, required this.onLimpar});

  final bool vazioGeral;
  final VoidCallback onLimpar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pets, size: 64, color: AppCores.borda),
            const SizedBox(height: 12),
            Text(
              vazioGeral ? 'Nenhum anúncio ainda' : 'Nenhum pet encontrado',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              vazioGeral
                  ? 'Que bom: ninguém anunciou pet perdido por enquanto.'
                  : 'Tente mudar a busca ou o filtro.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppCores.textoSuave),
            ),
            if (!vazioGeral) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: onLimpar,
                child: const Text('Limpar busca'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErroCarregar extends StatelessWidget {
  const _ErroCarregar({required this.onTentar});

  final VoidCallback onTentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: AppCores.borda),
            const SizedBox(height: 12),
            const Text(
              'Não foi possível carregar os anúncios',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              'Verifique sua conexão e tente de novo.',
              style: TextStyle(color: AppCores.textoSuave),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onTentar,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
