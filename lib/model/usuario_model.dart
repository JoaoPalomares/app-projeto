class Usuario {
  Usuario({
    required this.uid,
    required this.nome,
    required this.email,
    required this.telefone,
  });

  /// Identificador do usuário no Firebase Authentication.
  final String uid;

  /// O nome pode ser alterado depois, na tela de Perfil.
  String nome;
  final String email;
  final String telefone;
}