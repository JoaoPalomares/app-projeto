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

  FiltroAdocao get filtro => _filtro;
  int get quantidadeFiltros => _filtro.quantidadeAtiva;

  /// Lista já filtrada por nome e pelos filtros aplicados.
  List<Animal> get animaisFiltrados {
    final busca = _busca.trim().toLowerCase();
    final cidade = _filtro.cidade.trim().toLowerCase();

    return _animais.where((animal) {
      if (busca.isNotEmpty && !animal.nome.toLowerCase().contains(busca)) {
        return false;
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
      if (cidade.isNotEmpty && !animal.cidade.toLowerCase().contains(cidade)) {
        return false;
      }
      if (_filtro.apenasVacinados && !animal.vacinado) return false;
      if (_filtro.apenasCastrados && !animal.castrado) return false;
      return true;
    }).toList();
  }

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