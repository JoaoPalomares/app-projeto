import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/adocao_controller.dart';
import '../core/app_routes.dart';
import '../core/app_tema.dart';
import '../model/animal_model.dart';
import 'adocao_filtros_sheet.dart';

class AdocaoView extends StatelessWidget {
  const AdocaoView({super.key});

  void _abrirFiltros(BuildContext context) {
    final controller = context.read<AdocaoController>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => FiltrosSheet(
        filtroAtual: controller.filtro,
        onAplicar: controller.aplicarFiltro,
      ),
    );
  }

  void _abrirDetalhes(BuildContext context, Animal animal) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => _DetalhesAnimal(
        animal: animal,
        onAdotar: () {
          Navigator.pop(sheetContext);
          _querAdotar(context, animal);
        },
      ),
    );
  }

  /// Leva para a tela de triagem (próxima funcionalidade), enviando o animal.
  void _querAdotar(BuildContext context, Animal animal) {
    Navigator.pushNamed(context, AppRoutes.triagem, arguments: animal);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdocaoController>();
    final animais = controller.animaisFiltrados;
    final total = animais.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Portal de Adoção')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.buscaController,
                    onChanged: controller.buscarPorNome,
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      hintText: 'Buscar por nome...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Badge(
                  isLabelVisible: controller.quantidadeFiltros > 0,
                  label: Text('${controller.quantidadeFiltros}'),
                  child: IconButton.filled(
                    tooltip: 'Filtros',
                    onPressed: () => _abrirFiltros(context),
                    icon: const Icon(Icons.tune),
                    style: IconButton.styleFrom(
                      backgroundColor: AppCores.verde,
                      foregroundColor: Colors.white,
                      fixedSize: const Size(56, 56),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                total == 1
                    ? '1 pet disponível para adoção'
                    : '$total pets disponíveis para adoção',
                style: const TextStyle(
                  color: AppCores.verde,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: animais.isEmpty
                ? _SemResultados(onLimpar: controller.limparFiltros)
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 240,
                      mainAxisExtent: 350,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: animais.length,
                    itemBuilder: (context, index) {
                      final animal = animais[index];
                      return _CardAnimal(
                        animal: animal,
                        onTap: () => _abrirDetalhes(context, animal),
                        onAdotar: () => _querAdotar(context, animal),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CardAnimal extends StatelessWidget {
  const _CardAnimal({
    required this.animal,
    required this.onTap,
    required this.onAdotar,
  });

  final Animal animal;
  final VoidCallback onTap;
  final VoidCallback onAdotar;

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
            Expanded(child: _FotoAnimal(animal: animal)),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    animal.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppCores.texto,
                    ),
                  ),
                  Text(
                    animal.raca,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppCores.textoSuave,
                    ),
                  ),
                  if (animal.vacinado || animal.castrado) ...[
                    const SizedBox(height: 8),
                    _SelosSaude(animal: animal),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '${animal.idadeFormatada} • ${animal.sexo.rotulo}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 2),
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
                          animal.cidade,
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
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: onAdotar,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                    ),
                    child: const Text('Quero adotar'),
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

/// Foto do animal. Sem imagem em assets, mostra um ícone de patinha.
class _FotoAnimal extends StatelessWidget {
  const _FotoAnimal({required this.animal, this.tamanhoIcone = 48});

  final Animal animal;
  final double tamanhoIcone;

  @override
  Widget build(BuildContext context) {
    final gato = animal.especie == Especie.gato;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (animal.imagem != null)
          Image.asset(animal.imagem!, fit: BoxFit.cover)
        else
          ColoredBox(
            color: gato ? const Color(0xFFD9F2EF) : const Color(0xFFFBE3DC),
            child: Center(
              child: Icon(
                Icons.pets,
                size: tamanhoIcone,
                color: gato ? AppCores.verde : AppCores.coral,
              ),
            ),
          ),
        Positioned(
          top: 8,
          left: 8,
          child: _Selo(
            texto: animal.especie.rotulo,
            fundo: Colors.white,
            corTexto: AppCores.texto,
          ),
        ),
      ],
    );
  }
}

class _SelosSaude extends StatelessWidget {
  const _SelosSaude({required this.animal});

  final Animal animal;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        if (animal.vacinado)
          const _Selo(
            texto: 'Vacinado',
            fundo: Color(0xFFDCFCE7),
            corTexto: Color(0xFF166534),
            icone: Icons.check_circle_outline,
          ),
        if (animal.castrado)
          const _Selo(
            texto: 'Castrado',
            fundo: Color(0xFFDCFCE7),
            corTexto: Color(0xFF166534),
            icone: Icons.check_circle_outline,
          ),
      ],
    );
  }
}

class _Selo extends StatelessWidget {
  const _Selo({
    required this.texto,
    required this.fundo,
    required this.corTexto,
    this.icone,
  });

  final String texto;
  final Color fundo;
  final Color corTexto;
  final IconData? icone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null) ...[
            Icon(icone, size: 12, color: corTexto),
            const SizedBox(width: 3),
          ],
          Text(
            texto,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: corTexto,
            ),
          ),
        ],
      ),
    );
  }
}

/// Perfil completo do animal, aberto ao tocar no card.
class _DetalhesAnimal extends StatelessWidget {
  const _DetalhesAnimal({required this.animal, required this.onAdotar});

  final Animal animal;
  final VoidCallback onAdotar;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 180,
                child: _FotoAnimal(animal: animal, tamanhoIcone: 72),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              animal.nome,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppCores.texto,
              ),
            ),
            Text(
              animal.raca,
              style: const TextStyle(color: AppCores.textoSuave),
            ),
            const SizedBox(height: 12),
            _SelosSaude(animal: animal),
            const SizedBox(height: 16),
            _LinhaInfo(icone: Icons.cake_outlined, texto: animal.idadeFormatada),
            _LinhaInfo(
              icone: animal.sexo == Sexo.macho ? Icons.male : Icons.female,
              texto: animal.sexo.rotulo,
            ),
            _LinhaInfo(
              icone: Icons.straighten,
              texto: 'Porte ${animal.porte.rotulo.toLowerCase()}',
            ),
            _LinhaInfo(
              icone: Icons.location_on_outlined,
              texto: animal.cidade,
            ),
            _LinhaInfo(
              icone: Icons.volunteer_activism_outlined,
              texto: 'Por ${animal.ong}',
            ),
            const SizedBox(height: 12),
            Text(animal.descricao, style: const TextStyle(height: 1.4)),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAdotar,
              icon: const Icon(Icons.favorite_border),
              label: const Text('Quero adotar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinhaInfo extends StatelessWidget {
  const _LinhaInfo({required this.icone, required this.texto});

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icone, size: 18, color: AppCores.verde),
          const SizedBox(width: 8),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }
}

class _SemResultados extends StatelessWidget {
  const _SemResultados({required this.onLimpar});

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
            const Text(
              'Nenhum pet encontrado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tente mudar ou limpar os filtros.',
              style: TextStyle(color: AppCores.textoSuave),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: onLimpar, child: const Text('Limpar filtros')),
          ],
        ),
      ),
    );
  }
}