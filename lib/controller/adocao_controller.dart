import 'package:flutter/material.dart';

import '../core/animais_mock.dart';
import '../model/animal_model.dart';
import '../model/filtro_adocao_model.dart';

/// Estado e regras do Portal de Adoção (RF04).
class AdocaoController extends ChangeNotifier {
  final List<Animal> _animais = animaisMock;

  final buscaController = TextEditingController();

  FiltroAdocao _filtro = const FiltroAdocao();
  String _busca = '';

  /// Texto pesquisável de cada animal (nome, espécie e raça), já sem acento.
  /// Montado uma vez só, em vez de a cada letra digitada.
  late final Map<int, String> _indiceBusca = {
    for (final animal in _animais) animal.id: _textoPesquisavel(animal),
  };

  FiltroAdocao get filtro => _filtro;
  int get quantidadeFiltros => _filtro.quantidadeAtiva;

  /// Lista já filtrada pela busca e pelos filtros aplicados.
  List<Animal> get animaisFiltrados {
    final palavras = _palavrasDaBusca(_busca);
    final cidade = _normalizar(_filtro.cidade);

    return _animais.where((animal) {
      if (palavras.isNotEmpty) {
        final texto = _indiceBusca[animal.id]!;
        // Todas as palavras digitadas precisam aparecer (ex.: "gato siames").
        if (!palavras.every(texto.contains)) return false;
      }
      if (_filtro.especie != null && animal.especie != _filtro.especie) {
        return false;
      }
      if (_filtro.porte != null && animal.porte != _filtro.porte) {
        return false;
      }
      if (_filtro.sexo != null && animal.sexo != _filtro.sexo) {
        return false;
      }
      if (_filtro.faixaEtaria != null &&
          animal.faixaEtaria != _filtro.faixaEtaria) {
        return false;
      }
      if (cidade.isNotEmpty && !_normalizar(animal.cidade).contains(cidade)) {
        return false;
      }
      if (_filtro.apenasVacinados && !animal.vacinado) return false;
      if (_filtro.apenasCastrados && !animal.castrado) return false;
      return true;
    }).toList();
  }

  /// Busca por nome, espécie ou raça (o nome do método foi mantido para a
  /// view continuar funcionando sem alterações).
  void buscarPorNome(String texto) {
    _busca = texto;
    notifyListeners();
  }

  void aplicarFiltro(FiltroAdocao novoFiltro) {
    _filtro = novoFiltro;
    notifyListeners();
  }

  void limparFiltros() {
    _filtro = const FiltroAdocao();
    _busca = '';
    buscaController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    buscaController.dispose();
    super.dispose();
  }
}

/// Palavras que o usuário pode digitar no lugar de outras.
const _sinonimos = {
  'cao': 'cachorro',
  'caes': 'cachorro',
  'cachorros': 'cachorro',
  'cachorra': 'cachorro',
  'cachorrinho': 'cachorro',
  'gatos': 'gato',
  'gata': 'gato',
  'gatas': 'gato',
  'gatinho': 'gato',
  'gatinha': 'gato',
};

/// Minúsculas, sem acento e sem hífen: "Siamês" e "siames" viram o mesmo texto.
String _normalizar(String texto) {
  const comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const semAcento = 'aaaaaeeeeiiiiooooouuuucn';

  final buffer = StringBuffer();
  for (final letra in texto.toLowerCase().split('')) {
    final posicao = comAcento.indexOf(letra);
    buffer.write(posicao >= 0 ? semAcento[posicao] : letra);
  }

  return buffer
      .toString()
      .replaceAll('-', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// Divide o que foi digitado em palavras e troca os sinônimos.
List<String> _palavrasDaBusca(String busca) {
  final normalizado = _normalizar(busca);
  if (normalizado.isEmpty) return const [];

  return normalizado
      .split(' ')
      .map((palavra) => _sinonimos[palavra] ?? palavra)
      .toList();
}

/// Junta nome, espécie e raça em um texto só para pesquisar.
/// Também guarda uma versão sem espaços, para "viralata" achar "vira lata".
String _textoPesquisavel(Animal animal) {
  final raca = _normalizar(animal.raca);

  final partes = [
    _normalizar(animal.nome),
    _normalizar(animal.especie.rotulo),
    raca,
  ];

  // Cães sem raça definida: "srd", "vira-lata" e "sem raça" valem para todos.
  final semRaca = raca.contains('srd') ||
      raca.contains('vira lata') ||
      raca.contains('sem raca');
  if (semRaca) partes.add('srd vira lata sem raca definida');

  final texto = partes.join(' ');
  return '$texto ${texto.replaceAll(' ', '')}';
}