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
    this.fotoUrl,
    this.ongUid,
  });

  /// Id do documento no Firestore.
  final String id;
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

  /// Caminho de uma foto em assets (usado só nos exemplos locais).
  final String? imagem;

  /// Link de uma foto na internet, informado pela ONG.
  final String? fotoUrl;

  /// uid da ONG que cadastrou o animal.
  final String? ongUid;

  /// Monta o animal a partir de um documento da coleção `animais`.
  factory Animal.fromMap(String id, Map<String, dynamic> dados) {
    final foto = dados['fotoUrl'] as String?;

    return Animal(
      id: id,
      nome: dados['nome'] as String? ?? '',
      especie: Especie.values.asNameMap()[dados['especie']] ?? Especie.cachorro,
      raca: dados['raca'] as String? ?? '',
      idadeMeses: (dados['idadeMeses'] as num?)?.toInt() ?? 0,
      porte: Porte.values.asNameMap()[dados['porte']] ?? Porte.medio,
      sexo: Sexo.values.asNameMap()[dados['sexo']] ?? Sexo.macho,
      cidade: dados['cidade'] as String? ?? '',
      ong: dados['ong'] as String? ?? '',
      descricao: dados['descricao'] as String? ?? '',
      vacinado: dados['vacinado'] as bool? ?? false,
      castrado: dados['castrado'] as bool? ?? false,
      fotoUrl: (foto == null || foto.isEmpty) ? null : foto,
      ongUid: dados['ongUid'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'nome': nome,
        'especie': especie.name,
        'raca': raca,
        'idadeMeses': idadeMeses,
        'porte': porte.name,
        'sexo': sexo.name,
        'cidade': cidade,
        'ong': ong,
        'descricao': descricao,
        'vacinado': vacinado,
        'castrado': castrado,
        'fotoUrl': fotoUrl,
        'ongUid': ongUid,
      };

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