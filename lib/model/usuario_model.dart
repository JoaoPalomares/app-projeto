class Usuario {
  Usuario({
    required this.uid,
    required this.nome,
    required this.email,
    required this.telefone,
    this.tipo = tipoAdotante,
    this.cidade = '',
    this.estado = '',
  });

  static const tipoAdotante = 'adotante';
  static const tipoOng = 'ong';

  /// Identificador do usuário no Firebase Authentication.
  final String uid;

  /// O nome pode ser alterado depois, na tela de Perfil.
  String nome;
  final String email;
  final String telefone;

  /// 'adotante' ou 'ong'.
  final String tipo;

  /// Preenchidos só nas contas de ONG.
  final String cidade;
  final String estado;

  bool get ehOng => tipo == tipoOng;
}