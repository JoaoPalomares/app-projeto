import 'package:flutter/material.dart';

import '../controller/agendar_controller.dart';
import '../core/app_tema.dart';
import '../core/dependencias.dart';

class AgendarView extends StatefulWidget {
  const AgendarView({super.key});

  @override
  State<AgendarView> createState() => _AgendarViewState();
}

class _AgendarViewState extends State<AgendarView> {
  final _controller = g<AgendarController>();
  final _formKey = GlobalKey<FormState>();
  final _nomePetCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  String? _servico;
  DateTime? _data;
  TimeOfDay? _hora;
  String? _erroDataHora;

  @override
  void dispose() {
    _nomePetCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  String _dois(int n) => n.toString().padLeft(2, '0');
  String _formatarData(DateTime d) => '${_dois(d.day)}/${_dois(d.month)}/${d.year}';
  String _formatarHora(TimeOfDay h) => '${_dois(h.hour)}:${_dois(h.minute)}';

  Future<void> _escolherData() async {
    final agora = DateTime.now();
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _data ?? agora,
      firstDate: agora,
      lastDate: agora.add(const Duration(days: 365)),
    );
    if (escolhida != null) setState(() => _data = escolhida);
  }

  Future<void> _escolherHora() async {
    final escolhida = await showTimePicker(
      context: context,
      initialTime: _hora ?? TimeOfDay.now(),
    );
    if (escolhida != null) setState(() => _hora = escolhida);
  }

  void _enviar() {
    final formOk = _formKey.currentState!.validate();
    final erro = _controller.validarDataHora(_data, _hora);
    setState(() => _erroDataHora = erro);
    if (!formOk || erro != null) return;

    _controller.agendar(
      nomePet: _nomePetCtrl.text,
      servico: _servico!,
      data: _data!,
      hora: _hora!,
      observacao: _obsCtrl.text,
    );

    _formKey.currentState!.reset();
    _nomePetCtrl.clear();
    _obsCtrl.clear();
    setState(() {
      _servico = null;
      _data = null;
      _hora = null;
      _erroDataHora = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Agendamento realizado com sucesso')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agendar')),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final lista = _controller.agendamentos;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nomePetCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nome do pet',
                        prefixIcon: Icon(Icons.pets),
                      ),
                      validator: _controller.validarNomePet,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _servico,
                      decoration: const InputDecoration(
                        labelText: 'Serviço',
                        prefixIcon: Icon(Icons.medical_services_outlined),
                      ),
                      items: AgendarController.servicos
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => _servico = v),
                      validator: _controller.validarServico,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _escolherData,
                            icon: const Icon(Icons.calendar_month),
                            label: Text(
                              _data == null ? 'Data' : _formatarData(_data!),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _escolherHora,
                            icon: const Icon(Icons.access_time),
                            label: Text(
                              _hora == null ? 'Horário' : _formatarHora(_hora!),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_erroDataHora != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 12),
                        child: Text(
                          _erroDataHora!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
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
                      onPressed: _enviar,
                      icon: const Icon(Icons.event_available),
                      label: const Text('Agendar'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Meus agendamentos',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (lista.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('Nenhum agendamento ainda')),
                )
              else
                ...lista.map(
                  (a) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.event, color: AppCores.coral),
                      title: Text('${a.servico} • ${a.nomePet}'),
                      subtitle: Text(
                        '${_formatarData(a.dataHora)} às '
                        '${_formatarHora(TimeOfDay.fromDateTime(a.dataHora))}'
                        '${a.observacao.isEmpty ? '' : '\n${a.observacao}'}',
                      ),
                      isThreeLine: a.observacao.isNotEmpty,
                      trailing: IconButton(
                        tooltip: 'Cancelar',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _controller.cancelar(a.id),
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