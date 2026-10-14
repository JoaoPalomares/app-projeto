enum Especie {
  cachorro('Cachorro'),
  gato('Gato');

  const Especie(this.rotulo);
  final String rotulo;
}

enum Porte {
  pequeno('Pequeno'),
  medio('Médio'),
  grande('Grande');

  const Porte(this.rotulo);
  final String rotulo;
}

enum Sexo {
  macho('Macho'),
  femea('Fêmea');

  const Sexo(this.rotulo);
  final String rotulo;
}

enum FaixaEtaria {
  filhote('Filhote'),
  adulto('Adulto'),
  idoso('Idoso');

  const FaixaEtaria(this.rotulo);
  final String rotulo;
}

class Animal {
  const Animal({
    required this.id,
    required this.nome,
    required this.especie,
    required this.raca,
    required this.idadeMeses,
    required this.porte,
    required this.sexo,
    required this.cidade,
    required this.ong,
    required this.descricao,
    this.vacinado = false,
    this.castrado = false,
    this.imagem,
  });

  final int id;
  final String nome;
  final Especie especie;
  final String raca;
  final int idadeMeses;
  final Porte porte;
  final Sexo sexo;
  final String cidade;
  final String ong;
  final String descricao;
  final bool vacinado;
  final bool castrado;

  /// Caminho de uma foto em assets (opcional). Sem foto, a tela usa um ícone.
  final String? imagem;

  FaixaEtaria get faixaEtaria {
    if (idadeMeses < 12) return FaixaEtaria.filhote;
    if (idadeMeses < 84) return FaixaEtaria.adulto; // até 7 anos
    return FaixaEtaria.idoso;
  }

  String get idadeFormatada {
    if (idadeMeses < 12) {
      return idadeMeses == 1 ? '1 mês' : '$idadeMeses meses';
    }
    final anos = idadeMeses ~/ 12;
    return anos == 1 ? '1 ano' : '$anos anos';
  }
}