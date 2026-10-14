class Usuario {
  Usuario({
    required this.nome,
    required this.email,
    required this.telefone,
    required this.senha,
  });

  /// O nome pode ser alterado depois, na tela de Perfil.
  String nome;
  final String email;
  final String telefone;
  final String senha;
}