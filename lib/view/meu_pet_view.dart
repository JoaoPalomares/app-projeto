import 'package:flutter/material.dart';

import '../controller/meu_pet_controller.dart';
import '../core/app_tema.dart';
import '../core/dependencias.dart';
import '../model/pet_model.dart';

class MeuPetView extends StatefulWidget {
  const MeuPetView({super.key});

  @override
  State<MeuPetView> createState() => _MeuPetViewState();
}

class _MeuPetViewState extends State<MeuPetView> {
  final _controller = g<MeuPetController>();
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _racaCtrl = TextEditingController();
  final _idadeCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();
  String? _especie;
  bool _salvando = false;

  // Stream dos pets do usuário (RF004). É recriada no "Tentar novamente".
  late Stream<List<PetModel>> _stream = _controller.streamPets();

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _racaCtrl.dispose();
    _idadeCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  void _mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  /// RF003: grava no Firestore e informa sucesso ou erro.
  Future<void> _salvar() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);
    final erro = await _controller.adicionar(
      nome: _nomeCtrl.text,
      especie: _especie!,
      idadeAnos: int.parse(_idadeCtrl.text.trim()),
      raca: _racaCtrl.text,
      observacao: _obsCtrl.text,
    );
    if (!mounted) return;
    setState(() => _salvando = false);

    if (erro != null) {
      _mostrarMensagem(erro);
      return;
    }

    _formKey.currentState?.reset();
    _nomeCtrl.clear();
    _racaCtrl.clear();
    _idadeCtrl.clear();
    _obsCtrl.clear();
    setState(() => _especie = null);
    _mostrarMensagem('Pet cadastrado com sucesso');
  }

  Future<void> _remover(String id) async {
    final erro = await _controller.remover(id);
    if (!mounted) return;
    _mostrarMensagem(erro ?? 'Pet removido');
  }

  /// Aviso exibido no lugar da lista (carregando, erro ou lista vazia).
  Widget? _aviso(AsyncSnapshot<List<PetModel>> snapshot) {
    if (snapshot.hasError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            const Text(
              'Não foi possível carregar seus pets.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => setState(() => _stream = _controller.streamPets()),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    if (!snapshot.hasData) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (snapshot.data!.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('Você ainda não cadastrou pets')),
      );
    }
    return null;
  }

  Widget _formulario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomeCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nome do pet',
                  prefixIcon: Icon(Icons.pets),
                ),
                validator: _controller.validarNome,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _especie,
                decoration: const InputDecoration(
                  labelText: 'Espécie',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: MeuPetController.especies
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _especie = v),
                validator: _controller.validarEspecie,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _racaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Raça (opcional)',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _idadeCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Idade (anos)',
                  prefixIcon: Icon(Icons.cake_outlined),
                ),
                validator: _controller.validarIdade,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _obsCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Observação (opcional)',
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _salvando ? null : _salvar,
                icon: _salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                label: const Text('Cadastrar pet'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Meus pets', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _cartaoPet(PetModel p) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFFBE3DC),
          child: Icon(Icons.pets, color: AppCores.coral),
        ),
        title: Text(p.nome),
        subtitle: Text(
          '${p.especie} • ${p.idadeAnos} '
          '${p.idadeAnos == 1 ? 'ano' : 'anos'}'
          '${p.raca.isEmpty ? '' : ' • ${p.raca}'}'
          '${p.observacao.isEmpty ? '' : '\n${p.observacao}'}',
        ),
        isThreeLine: p.observacao.isNotEmpty,
        trailing: IconButton(
          tooltip: 'Remover',
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _remover(p.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Pet')),
      // RF004: StreamBuilder + ListView em tempo real. O item 0 é o formulário.
      body: StreamBuilder<List<PetModel>>(
        stream: _stream,
        builder: (context, snapshot) {
          final pets = snapshot.data ?? const <PetModel>[];
          final aviso = _aviso(snapshot);
          final quantidade = aviso == null ? pets.length : 1;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 1 + quantidade,
            itemBuilder: (context, i) {
              if (i == 0) return _formulario();
              if (aviso != null) return aviso;
              return _cartaoPet(pets[i - 1]);
            },
          );
        },
      ),
    );
  }
}