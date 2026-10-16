import 'package:flutter/material.dart';

import '../controller/meu_pet_controller.dart';
import '../core/app_tema.dart';
import '../core/dependencias.dart';

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

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _racaCtrl.dispose();
    _idadeCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  void _salvar() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    _controller.adicionar(
      nome: _nomeCtrl.text,
      especie: _especie!,
      idadeAnos: int.parse(_idadeCtrl.text.trim()),
      raca: _racaCtrl.text,
      observacao: _obsCtrl.text,
    );

    _formKey.currentState!.reset();
    _nomeCtrl.clear();
    _racaCtrl.clear();
    _idadeCtrl.clear();
    _obsCtrl.clear();
    setState(() => _especie = null);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pet cadastrado com sucesso')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Pet')),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final pets = _controller.pets;
          return ListView(
            padding: const EdgeInsets.all(16),
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
                      onPressed: _salvar,
                      icon: const Icon(Icons.add),
                      label: const Text('Cadastrar pet'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Meus pets', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (pets.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('Você ainda não cadastrou pets')),
                )
              else
                ...pets.map(
                  (p) => Card(
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
                        onPressed: () => _controller.remover(p.id),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}