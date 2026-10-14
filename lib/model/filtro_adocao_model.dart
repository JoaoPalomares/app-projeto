import 'animal_model.dart';

/// Filtros aplicados na listagem (RF04). `null` / vazio / false = sem filtro.
class FiltroAdocao {
  const FiltroAdocao({
    this.especie,
    this.porte,
    this.sexo,
    this.faixaEtaria,
    this.cidade = '',
    this.apenasVacinados = false,
    this.apenasCastrados = false,
  });

  final Especie? especie;
  final Porte? porte;
  final Sexo? sexo;
  final FaixaEtaria? faixaEtaria;
  final String cidade;
  final bool apenasVacinados;
  final bool apenasCastrados;

  int get quantidadeAtiva => [
        especie != null,
        porte != null,
        sexo != null,
        faixaEtaria != null,
        cidade.trim().isNotEmpty,
        apenasVacinados,
        apenasCastrados,
      ].where((ativo) => ativo).length;
}