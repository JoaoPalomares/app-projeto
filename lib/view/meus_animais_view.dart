import 'package:flutter/material.dart';

import '../controller/animais_controller.dart';
import '../core/app_tema.dart';
import '../core/dependencias.dart';
import '../model/animal_model.dart';

/// Área da ONG: lista em tempo real os animais que ela cadastrou.
class MeusAnimaisView extends StatefulWidget {
  const MeusAnimaisView({super.key});

  @override
  State<MeusAnimaisView> createState() => _MeusAnimaisViewState();
}

class _MeusAnimaisViewState extends State<MeusAnimaisView> {
  final _controller = g<AnimaisController>();
  late Stream<List<Animal>> _stream = _controller.meus();

  void _tentarNovamente() => setState(() => _stream = _controller.meus());

  Future<void> _abrirCadastro() async {
    final mensagens = ScaffoldMessenger.of(context);

    final cadastrou = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _FormularioAnimal(),
    );

    if (cadastrou == true) {
      mensagens.showSnackBar(
        const SnackBar(content: Text('Animal cadastrado com sucesso!')),
      );
    }
  }

  Future<void> _excluir(Animal animal) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: Text('Excluir ${animal.nome}?'),
        content: const Text(
          'O animal deixará de aparecer para quem quer adotar.',
        ),
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

    final erro = await _controller.excluir(animal.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(erro ?? 'Animal excluído.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus animais')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: FilledButton.icon(
              onPressed: _abrirCadastro, // o mesmo onPressed do botão antigo
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar animal'),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Animal>>(
              stream: _stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _MensagemCentral(
                    icone: Icons.cloud_off,
                    titulo: 'Não foi possível carregar',
                    texto: 'Verifique sua conexão e tente de novo.',
                    rotuloBotao: 'Tentar novamente',
                    onPressed: _tentarNovamente,
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final animais = snapshot.data!;
                if (animais.isEmpty) {
                  return const _MensagemCentral(
                    icone: Icons.pets,
                    titulo: 'Nenhum animal cadastrado',
                    texto:
                        'Toque em "Cadastrar animal" para o primeiro aparecer '
                        'na lista de adoção.',
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    MediaQuery.paddingOf(context).bottom + 88,
                  ),
                  itemCount: animais.length,
                  separatorBuilder: (context, indice) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, indice) {
                    final animal = animais[indice];
                    return _CartaoAnimal(
                      animal: animal,
                      onExcluir: () => _excluir(animal),
                    );
                  },
                );
              },
            ), // o StreamBuilder que já estava lá
          ),
        ],
      ),
    );
  }
}

class _CartaoAnimal extends StatelessWidget {
  const _CartaoAnimal({required this.animal, required this.onExcluir});

  final Animal animal;
  final VoidCallback onExcluir;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppCores.borda),
      ),
      child: Row(
        children: [
          _Foto(url: animal.fotoUrl, largura: 76, altura: 76),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  animal.nome,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppCores.texto,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${animal.especie.rotulo} • ${animal.raca}',
                  style: const TextStyle(color: AppCores.textoSuave),
                ),
                Text(
                  '${animal.cidade} • ${animal.idadeFormatada}',
                  style: const TextStyle(
                    color: AppCores.textoSuave,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Excluir',
            onPressed: onExcluir,
            icon: const Icon(Icons.delete_outline, color: AppCores.coral),
          ),
        ],
      ),
    );
  }
}

/// Foto vinda de um link; sem link (ou com link quebrado) mostra um ícone.
class _Foto extends StatelessWidget {
  const _Foto({required this.url, required this.largura, required this.altura});

  final String? url;
  final double largura;
  final double altura;

  @override
  Widget build(BuildContext context) {
    const semFoto = ColoredBox(
      color: AppCores.fundo,
      child: Center(child: Icon(Icons.pets, color: AppCores.borda, size: 32)),
    );

    final link = url;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: largura,
        height: altura,
        child: (link == null || link.isEmpty)
            ? semFoto
            : Image.network(
                link,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => semFoto,
              ),
      ),
    );
  }
}

class _MensagemCentral extends StatelessWidget {
  const _MensagemCentral({
    required this.icone,
    required this.titulo,
    required this.texto,
    this.rotuloBotao,
    this.onPressed,
  });

  final IconData icone;
  final String titulo;
  final String texto;
  final String? rotuloBotao;
  final VoidCallback? onPressed;

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
            if (rotuloBotao != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onPressed, child: Text(rotuloBotao!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Formulário de cadastro, aberto em uma folha na parte de baixo da tela.
class _FormularioAnimal extends StatefulWidget {
  const _FormularioAnimal();

  @override
  State<_FormularioAnimal> createState() => _FormularioAnimalState();
}

class _FormularioAnimalState extends State<_FormularioAnimal> {
  final _controller = g<AnimaisController>();
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _raca = TextEditingController();
  final _idade = TextEditingController();
  final _cidade = TextEditingController();
  final _descricao = TextEditingController();
  final _foto = TextEditingController();

  Especie _especie = Especie.cachorro;
  Porte _porte = Porte.medio;
  Sexo _sexo = Sexo.macho;
  bool _idadeEmAnos = true;
  bool _vacinado = false;
  bool _castrado = false;
  String? _erro;

  @override
  void dispose() {
    _nome.dispose();
    _raca.dispose();
    _idade.dispose();
    _cidade.dispose();
    _descricao.dispose();
    _foto.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _erro = null);

    final numero = int.parse(_idade.text.trim());
    final erro = await _controller.cadastrar(
      nome: _nome.text,
      especie: _especie,
      raca: _raca.text,
      idadeMeses: _idadeEmAnos ? numero * 12 : numero,
      porte: _porte,
      sexo: _sexo,
      cidade: _cidade.text,
      descricao: _descricao.text,
      vacinado: _vacinado,
      castrado: _castrado,
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
                'Cadastrar animal',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppCores.texto,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Preencha os dados para o animal aparecer na lista de adoção.',
                style: TextStyle(color: AppCores.textoSuave),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nome,
                textCapitalization: TextCapitalization.words,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: _controller.validarNome,
                decoration: const InputDecoration(
                  labelText: 'Nome do animal',
                  prefixIcon: Icon(Icons.pets),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Especie>(
                      initialValue: _especie,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Espécie'),
                      items: [
                        for (final item in Especie.values)
                          DropdownMenuItem(
                            value: item,
                            child: Text(item.rotulo),
                          ),
                      ],
                      onChanged: (valor) =>
                          setState(() => _especie = valor ?? _especie),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<Sexo>(
                      initialValue: _sexo,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Sexo'),
                      items: [
                        for (final item in Sexo.values)
                          DropdownMenuItem(
                            value: item,
                            child: Text(item.rotulo),
                          ),
                      ],
                      onChanged: (valor) =>
                          setState(() => _sexo = valor ?? _sexo),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _raca,
                textCapitalization: TextCapitalization.words,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: _controller.validarRaca,
                decoration: const InputDecoration(
                  labelText: 'Raça',
                  hintText: 'Ex.: SRD (vira-lata), Siamês, Labrador',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _idade,
                      keyboardType: TextInputType.number,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: _controller.validarIdade,
                      decoration: const InputDecoration(
                        labelText: 'Idade',
                        prefixIcon: Icon(Icons.cake_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<bool>(
                      initialValue: _idadeEmAnos,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Unidade'),
                      items: const [
                        DropdownMenuItem(value: true, child: Text('Anos')),
                        DropdownMenuItem(value: false, child: Text('Meses')),
                      ],
                      onChanged: (valor) =>
                          setState(() => _idadeEmAnos = valor ?? true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Porte>(
                initialValue: _porte,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Porte'),
                items: [
                  for (final item in Porte.values)
                    DropdownMenuItem(value: item, child: Text(item.rotulo)),
                ],
                onChanged: (valor) => setState(() => _porte = valor ?? _porte),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cidade,
                textCapitalization: TextCapitalization.words,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: _controller.validarCidade,
                decoration: const InputDecoration(
                  labelText: 'Cidade',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricao,
                minLines: 3,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: _controller.validarDescricao,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Personalidade, cuidados, como foi resgatado...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Vacinado'),
                value: _vacinado,
                onChanged: (valor) => setState(() => _vacinado = valor),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Castrado'),
                value: _castrado,
                onChanged: (valor) => setState(() => _castrado = valor),
              ),
              const SizedBox(height: 8),
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
                    child: _Foto(
                      url: link,
                      largura: double.infinity,
                      altura: 150,
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
                      : const Text('Cadastrar animal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
