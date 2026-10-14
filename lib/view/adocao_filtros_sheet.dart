import 'package:flutter/material.dart';

import '../core/app_tema.dart';
import '../model/animal_model.dart';
import '../model/filtro_adocao_model.dart';

/// Painel de filtros (espécie, porte, sexo, idade, cidade, vacinado, castrado).
/// Trabalha com uma cópia local e só envia ao controller ao tocar em "Aplicar".
class FiltrosSheet extends StatefulWidget {
  const FiltrosSheet({
    super.key,
    required this.filtroAtual,
    required this.onAplicar,
  });

  final FiltroAdocao filtroAtual;
  final ValueChanged<FiltroAdocao> onAplicar;

  @override
  State<FiltrosSheet> createState() => _FiltrosSheetState();
}

class _FiltrosSheetState extends State<FiltrosSheet> {
  Especie? _especie;
  Porte? _porte;
  Sexo? _sexo;
  FaixaEtaria? _faixaEtaria;
  bool _apenasVacinados = false;
  bool _apenasCastrados = false;
  late final TextEditingController _cidadeController;

  @override
  void initState() {
    super.initState();
    final filtro = widget.filtroAtual;
    _especie = filtro.especie;
    _porte = filtro.porte;
    _sexo = filtro.sexo;
    _faixaEtaria = filtro.faixaEtaria;
    _apenasVacinados = filtro.apenasVacinados;
    _apenasCastrados = filtro.apenasCastrados;
    _cidadeController = TextEditingController(text: filtro.cidade);
  }

  @override
  void dispose() {
    _cidadeController.dispose();
    super.dispose();
  }

  void _aplicar() {
    widget.onAplicar(
      FiltroAdocao(
        especie: _especie,
        porte: _porte,
        sexo: _sexo,
        faixaEtaria: _faixaEtaria,
        cidade: _cidadeController.text.trim(),
        apenasVacinados: _apenasVacinados,
        apenasCastrados: _apenasCastrados,
      ),
    );
    Navigator.pop(context);
  }

  void _limpar() {
    widget.onAplicar(const FiltroAdocao());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Sobe o painel quando o teclado abre.
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filtros',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Toque numa opção para filtrar; toque de novo para remover.',
                style: TextStyle(color: AppCores.textoSuave, fontSize: 12),
              ),
              const SizedBox(height: 16),
              _GrupoChips<Especie>(
                titulo: 'Espécie',
                opcoes: Especie.values,
                rotulo: (e) => e.rotulo,
                selecionado: _especie,
                onChanged: (valor) => setState(() => _especie = valor),
              ),
              _GrupoChips<Porte>(
                titulo: 'Porte',
                opcoes: Porte.values,
                rotulo: (p) => p.rotulo,
                selecionado: _porte,
                onChanged: (valor) => setState(() => _porte = valor),
              ),
              _GrupoChips<Sexo>(
                titulo: 'Sexo',
                opcoes: Sexo.values,
                rotulo: (s) => s.rotulo,
                selecionado: _sexo,
                onChanged: (valor) => setState(() => _sexo = valor),
              ),
              _GrupoChips<FaixaEtaria>(
                titulo: 'Idade',
                opcoes: FaixaEtaria.values,
                rotulo: (f) => f.rotulo,
                selecionado: _faixaEtaria,
                onChanged: (valor) => setState(() => _faixaEtaria = valor),
              ),
              TextField(
                controller: _cidadeController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Cidade',
                  hintText: 'Digite a cidade...',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Apenas vacinados'),
                value: _apenasVacinados,
                onChanged: (valor) => setState(() => _apenasVacinados = valor),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Apenas castrados'),
                value: _apenasCastrados,
                onChanged: (valor) => setState(() => _apenasCastrados = valor),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _limpar,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        foregroundColor: AppCores.verde,
                        side: const BorderSide(color: AppCores.verde),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Limpar filtros'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _aplicar,
                      child: const Text('Aplicar filtros'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grupo de opções (ChoiceChip) reutilizado para qualquer enum.
class _GrupoChips<T> extends StatelessWidget {
  const _GrupoChips({
    required this.titulo,
    required this.opcoes,
    required this.rotulo,
    required this.selecionado,
    required this.onChanged,
  });

  final String titulo;
  final List<T> opcoes;
  final String Function(T) rotulo;
  final T? selecionado;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final opcao in opcoes)
                ChoiceChip(
                  label: Text(rotulo(opcao)),
                  selected: opcao == selecionado,
                  selectedColor: const Color(0xFFFBE3DC),
                  onSelected: (marcado) => onChanged(marcado ? opcao : null),
                ),
            ],
          ),
        ],
      ),
    );
  }
}