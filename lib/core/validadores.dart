/// Validações reutilizáveis pelos formulários do app.
///
/// Cada método devolve `null` quando o valor é válido, ou a mensagem de erro
/// exibida abaixo do campo (padrão do `validator` do `TextFormField`).
class Validadores {
  Validadores._();

  static final RegExp _formatoEmail = RegExp(
    r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$',
  );

  static String? obrigatorio(
    String? valor, {
    String campo = 'Este campo',
    bool feminino = false,
  }) {
    if (valor == null || valor.trim().isEmpty) {
      return '$campo é ${feminino ? 'obrigatória' : 'obrigatório'}.';
    }
    return null;
  }

  static String? tamanhoMinimo(
    String? valor,
    int minimo, {
    String campo = 'Este campo',
  }) {
    final vazio = obrigatorio(valor, campo: campo);
    if (vazio != null) return vazio;

    if (valor!.trim().length < minimo) {
      return '$campo deve ter pelo menos $minimo caracteres.';
    }
    return null;
  }

  static String? email(String? valor) {
    final vazio = obrigatorio(valor, campo: 'O e-mail');
    if (vazio != null) return vazio;

    if (!_formatoEmail.hasMatch(valor!.trim())) {
      return 'Informe um e-mail válido (ex.: nome@email.com).';
    }
    return null;
  }

  /// Aceita telefone com DDD (10 ou 11 dígitos), com ou sem máscara.
  static String? telefone(String? valor) {
    final vazio = obrigatorio(valor, campo: 'O telefone');
    if (vazio != null) return vazio;

    final digitos = valor!.replaceAll(RegExp(r'\D'), '');
    if (digitos.length < 10 || digitos.length > 11) {
      return 'Informe um telefone válido com DDD.';
    }
    return null;
  }

  /// Senha de um novo cadastro: obrigatória e com tamanho mínimo.
  static String? senha(String? valor, {int minimo = 6}) {
    final vazio = obrigatorio(valor, campo: 'A senha', feminino: true);
    if (vazio != null) return vazio;

    if (valor!.length < minimo) {
      return 'A senha deve ter pelo menos $minimo caracteres.';
    }
    return null;
  }

  static String? confirmacaoSenha(String? valor, String senha) {
    final vazio = obrigatorio(
      valor,
      campo: 'A confirmação de senha',
      feminino: true,
    );
    if (vazio != null) return vazio;

    if (valor != senha) return 'As senhas não coincidem.';
    return null;
  }
}