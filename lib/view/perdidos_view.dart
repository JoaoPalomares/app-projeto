import 'package:flutter/material.dart';

import '../controller/perdidos_controller.dart';
import '../core/app_tema.dart';
import '../core/dependencias.dart';
import '../core/telefone_input_formatter.dart';

class PerdidosView extends StatefulWidget {
  const PerdidosView({super.key});

  @override
  State<PerdidosView> createState() => _PerdidosViewState();
}

class _PerdidosViewState extends State<PerdidosView> {
  final _controller = g<PerdidosController>();
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _localCtrl = TextEditingController();
  final _contatoCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String? _especie;
  DateTime? _data;
  String? _erroData;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _localCtrl.dispose();
    _contatoCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  String _dois(int n) => n.toString().padLeft(2, '0');
  String _formatarData(DateTime d) => '${_dois(d.day)}/${_dois(d.month)}/${d.year}';

  Future<void> _escolherData() async {
    final agora = DateTime.now();
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _data ?? agora,
      firstDate: agora.subtract(const Duration(days: 365)),
      lastDate: agora,
    );
    if (escolhida != null) setState(() => _data = escolhida);
  }

  void _reportar() {
    FocusScope.of(context).unfocus();
    final formOk = _formKey.currentState!.validate();
    final erro = _controller.validarData(_data);
    setState(() => _erroData = erro);
    if (!formOk || erro != null) return;

    _controller.reportar(
      nome: _nomeCtrl.text,
      especie: _especie!,
      localVisto: _localCtrl.text,
      data: _data!,
      contato: _contatoCtrl.text,
      descricao: _descCtrl.text,
    );

    _formKey.currentState!.reset();
    _nomeCtrl.clear();
    _localCtrl.clear();
    _contatoCtrl.clear();
    _descCtrl.clear();
    setState(() {
      _especie = null;
      _data = null;
      _erroData = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pet perdido reportado com sucesso')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pets Perdidos')),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final pets = _controller.pets;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Reportar pet perdido',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
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
                      items: PerdidosController.especies
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => _especie = v),
                      validator: _controller.validarEspecie,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _localCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Local onde foi visto pela última vez',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      validator: _controller.validarLocal,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _escolherData,
                      icon: const Icon(Icons.calendar_month),
                      label: Text(
                        _data == null
                            ? 'Data do desaparecimento'
                            : _formatarData(_data!),
                      ),
                    ),
                    if (_erroData != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 12),
                        child: Text(
                          _erroData!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _contatoCtrl,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [TelefoneInputFormatter()],
                      decoration: const InputDecoration(
                        labelText: 'Telefone para contato',
                        hintText: '(00) 00000-0000',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: _controller.validarContato,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Descrição (opcional)',
                        prefixIcon: Icon(Icons.notes),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _reportar,
                      icon: const Icon(Icons.campaign_outlined),
                      label: const Text('Reportar'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Pets desaparecidos', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (pets.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('Nenhum pet reportado')),
                )
              else
                ...pets.map(
                  (p) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: p.encontrado
                            ? const Color(0xFFDDF2E3)
                            : const Color(0xFFFBE3DC),
                        child: Icon(
                          p.encontrado ? Icons.check : Icons.location_on,
                          color: p.encontrado ? AppCores.verde : AppCores.coral,
                        ),
                      ),
                      title: Text('${p.nome} • ${p.especie}'),
                      subtitle: Text(
                        '${p.localVisto}\n'
                        'Desde ${_formatarData(p.dataDesaparecimento)} • ${p.contato}'
                        '${p.descricao.isEmpty ? '' : '\n${p.descricao}'}',
                      ),
                      isThreeLine: true,
                      trailing: TextButton(
                        onPressed: () => _controller.alternarEncontrado(p.id),
                        child: Text(p.encontrado ? 'Reabrir' : 'Encontrado'),
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