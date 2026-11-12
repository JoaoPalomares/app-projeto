import 'package:flutter/material.dart';

import '../controller/agendar_controller.dart';
import '../core/app_tema.dart';
import '../core/dependencias.dart';
import '../model/agendamento_model.dart';

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
  bool _salvando = false;

  // Stream dos agendamentos do usuário (RF004). Recriada no "Tentar novamente".
  late Stream<List<AgendamentoModel>> _stream =
      _controller.streamAgendamentos();

  static const _diasSemana = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  @override
  void dispose() {
    _nomePetCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  String _dois(int n) => n.toString().padLeft(2, '0');
  String _formatarData(DateTime d) =>
      '${_dois(d.day)}/${_dois(d.month)}/${d.year}';
  String _formatarHora(TimeOfDay h) => '${_dois(h.hour)}:${_dois(h.minute)}';
  String _rotuloData(DateTime d) =>
      '${_diasSemana[d.weekday - 1]}, ${_formatarData(d)}';

  void _mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _escolherData() async {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);

    final escolhida = await showDatePicker(
      context: context,
      helpText: 'Selecione a data',
      // A data inicial precisa ser um dia selecionável (seg a sex).
      initialDate: _controller.primeiroDiaUtil(_data ?? hoje),
      firstDate: hoje,
      lastDate: hoje.add(const Duration(days: 365)),
      selectableDayPredicate: _controller.diaUtil,
    );

    if (escolhida != null) {
      setState(() {
        _data = escolhida;
        _hora = null; // os horários livres mudam de um dia para o outro
        _erroDataHora = null;
      });
    }
  }

  /// RF003: grava no Firestore e informa sucesso ou erro.
  Future<void> _enviar() async {
    FocusScope.of(context).unfocus();
    final formOk = _formKey.currentState!.validate();
    final erro = _controller.validarDataHora(_data, _hora);
    setState(() => _erroDataHora = erro);
    if (!formOk || erro != null) return;

    setState(() => _salvando = true);
    final falha = await _controller.agendar(
      nomePet: _nomePetCtrl.text,
      servico: _servico!,
      data: _data!,
      hora: _hora!,
      observacao: _obsCtrl.text,
    );
    if (!mounted) return;
    setState(() => _salvando = false);

    if (falha != null) {
      _mostrarMensagem(falha);
      return;
    }

    _formKey.currentState?.reset();
    _nomePetCtrl.clear();
    _obsCtrl.clear();
    setState(() {
      _servico = null;
      _data = null;
      _hora = null;
      _erroDataHora = null;
    });
    _mostrarMensagem('Agendamento realizado com sucesso');
  }

  Future<void> _cancelar(String id) async {
    final erro = await _controller.cancelar(id);
    if (!mounted) return;
    _mostrarMensagem(erro ?? 'Agendamento cancelado');
  }

  /// Aviso exibido no lugar da lista (carregando, erro ou lista vazia).
  Widget? _aviso(AsyncSnapshot<List<AgendamentoModel>> snapshot) {
    if (snapshot.hasError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            const Text(
              'Não foi possível carregar seus agendamentos.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () =>
                  setState(() => _stream = _controller.streamAgendamentos()),
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
        child: Center(child: Text('Nenhum agendamento ainda')),
      );
    }
    return null;
  }

  Widget _formulario(List<AgendamentoModel> meus) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
              OutlinedButton.icon(
                onPressed: _escolherData,
                icon: const Icon(Icons.calendar_month),
                label: Text(
                  _data == null
                      ? 'Escolha a data (segunda a sexta)'
                      : _rotuloData(_data!),
                ),
              ),
              const SizedBox(height: 16),
              _secaoHorarios(meus),
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
                onPressed: _salvando ? null : _enviar,
                icon: _salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.event_available),
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
      ],
    );
  }

  Widget _cartaoAgendamento(AgendamentoModel a) {
    return Card(
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
          onPressed: () => _cancelar(a.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agendar')),
      // RF004: StreamBuilder + ListView em tempo real. O item 0 é o formulário.
      body: StreamBuilder<List<AgendamentoModel>>(
        stream: _stream,
        builder: (context, snapshot) {
          final lista = snapshot.data ?? const <AgendamentoModel>[];
          final aviso = _aviso(snapshot);
          final quantidade = aviso == null ? lista.length : 1;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 1 + quantidade,
            itemBuilder: (context, i) {
              if (i == 0) return _formulario(lista);
              if (aviso != null) return aviso;
              return _cartaoAgendamento(lista[i - 1]);
            },
          );
        },
      ),
    );
  }

  /// Grade de horários fixos do dia escolhido.
  Widget _secaoHorarios(List<AgendamentoModel> meus) {
    if (_data == null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppCores.borda),
        ),
        child: const Row(
          children: [
            Icon(Icons.access_time, color: AppCores.textoSuave),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Escolha a data para ver os horários disponíveis.',
                style: TextStyle(color: AppCores.textoSuave),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Horários disponíveis',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppCores.texto,
          ),
        ),
        const SizedBox(height: 8),
        const _Legenda(),
        const SizedBox(height: 16),
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 12,
            children: [
              for (final h in [
                ...AgendarController.horariosManha,
                ...AgendarController.horariosTarde,
              ])
                _chipHorario(h, meus),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chipHorario(TimeOfDay horario, List<AgendamentoModel> meus) {
    final indisponivel = _controller.horarioIndisponivel(_data!, horario, meus);
    final selecionado = !indisponivel && _hora == horario;

    return Container(
      decoration: BoxDecoration(
        color: indisponivel
            ? const Color(0xFFF3F4F6)
            : (selecionado ? AppCores.coral : Colors.white),
        borderRadius: BorderRadius.circular(10),
        // Sombra suave como na referência (some nos indisponíveis).
        boxShadow: indisponivel
            ? null
            : [
                BoxShadow(
                  color: AppCores.coral.withValues(alpha: 0.35),
                  blurRadius: 6,
                  offset: const Offset(2, 3),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: indisponivel
              ? null
              : () => setState(() {
                    _hora = horario;
                    _erroDataHora = null;
                  }),
          child: SizedBox(
            width: 72,
            height: 40,
            child: Center(
              child: Text(
                _formatarHora(horario),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: indisponivel
                      ? const Color(0xFF9CA3AF)
                      : (selecionado ? Colors.white : AppCores.coral),
                  decoration:
                      indisponivel ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Explica as cores dos horários.
class _Legenda extends StatelessWidget {
  const _Legenda();

  @override
  Widget build(BuildContext context) {
    Widget item(Color cor, Color borda, String texto) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: cor,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: borda),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              texto,
              style: const TextStyle(fontSize: 12, color: AppCores.textoSuave),
            ),
          ],
        );

    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: [
        item(Colors.white, AppCores.borda, 'Disponível'),
        item(AppCores.coral, AppCores.coral, 'Selecionado'),
        item(const Color(0xFFF3F4F6), Colors.transparent, 'Indisponível'),
      ],
    );
  }
}