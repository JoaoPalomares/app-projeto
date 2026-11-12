<div align="center">

# 🐾 Miaudote

### Adoção responsável, saúde do pet e comunidade — tudo na palma da mão.

![Flutter](https://img.shields.io/badge/Flutter-3.47.5-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.13.4-0175C2?logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20·%20Firestore%20·%20Hosting-FFCA28?logo=firebase&logoColor=black)
![Material 3](https://img.shields.io/badge/Material-3-E8735A)
![State](https://img.shields.io/badge/estado-ChangeNotifier-2D7A78)
![DI](https://img.shields.io/badge/DI-get__it-14B8A6)

**Projeto acadêmico desenvolvido por dois alunos da FATEC Ribeirão Preto · ADS**

</div>

---

## 📖 Sobre o projeto

O **Miaudote** é um aplicativo que conecta pessoas a animais que precisam de um lar e ajuda os tutores a cuidar da saúde dos seus pets. O tema nasceu no projeto de **Engenharia de Software II** (documentação, requisitos, casos de uso e protótipo interativo) e ganhou vida em **Flutter**, com **Firebase** como backend.

🌐 **Versão online:** [miaudote-ads.web.app](https://miaudote-ads.web.app)

---

## ✨ Funcionalidades

### Autenticação e conta
| Tela | O que faz |
|---|---|
| **Login** | Entra com e-mail e senha (ou com a conta Google) pelo **Firebase Authentication**, com mostrar/ocultar senha e mensagens de erro claras |
| **Cadastro** | Todos os campos obrigatórios, e-mail com formato válido, **máscara de telefone** e **senha forte**. O perfil fica salvo no Firestore |
| **Esqueceu a senha** | Envia por e-mail o link de redefinição de senha |
| **Perfil** | Dados do usuário, edição de nome e logout |
| **Sobre** | Integrantes, versão e informações do app |

### Adoção
| Tela | O que faz |
|---|---|
| **Portal de Adoção** | `GridView` de animais com foto, busca, filtros (espécie, porte, sexo, faixa etária) e detalhes em *bottom sheet* |
| **Triagem** | Recebe o animal escolhido, valida todos os campos e confirma a solicitação |

### Saúde do pet
| Tela | O que faz |
|---|---|
| **Meu Pet** | Cadastra, lista e remove os pets do usuário, com atualização **em tempo real** |
| **Agendar** | Marca consultas e serviços em dias úteis, com **horários fixos** e indicação dos horários indisponíveis. Os agendamentos aparecem em tempo real e podem ser cancelados |

### Experiência
- 🎉 **Modal de introdução** flutuante, exibido uma vez por sessão após o login, com 3 passos
- 👋 **Saudação personalizada** que atualiza em tempo real quando o nome é editado no Perfil
- 🧭 **Navegação inferior flutuante** (Material 3) entre as seções do app
- ✅ **Validação centralizada** com mensagens corretas em português (inclusive concordância de gênero)
- 🔒 **Dados separados por usuário:** cada pessoa só enxerga os próprios pets e agendamentos

---

## 🏗️ Arquitetura

Organização em `core/`, `model/`, `controller/` e `view/`. O estado é gerenciado com **`ChangeNotifier`**, a injeção de dependências é feita com **`get_it`**, e as telas reagem às mudanças com `ListenableBuilder`. Os dados do Firestore chegam às telas por `StreamBuilder`, em tempo real.

### Firebase
- **Authentication:** login, cadastro, login com Google e recuperação de senha.
- **Cloud Firestore:** coleções `usuarios`, `pets` e `agendamentos`. Todo documento guarda o `uid` do dono.
- **Regras de segurança** (`firestore.rules`): cada usuário só lê e grava os próprios documentos.
- **Hosting:** publicação da versão web.

---

## 🧰 Tecnologias

- [Flutter](https://flutter.dev) 3.47.5 e [Dart](https://dart.dev) 3.13.4
- Material 3 (`NavigationBar`, `FilledButton`, `ChoiceChip`, `showModalBottomSheet`, `Dialog`)
- [Firebase](https://firebase.google.com): Authentication, Cloud Firestore e Hosting
- [`get_it`](https://pub.dev/packages/get_it): injeção de dependências
- [`provider`](https://pub.dev/packages/provider): controllers escopados por rota
- [`device_preview_plus`](https://pub.dev/packages/device_preview_plus): testar diferentes dispositivos

---

## 🚀 Como executar

### Pré-requisitos
- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado (`flutter doctor` sem erros)
- Um emulador, um dispositivo físico ou o Chrome

### Passo a passo

```bash
# 1. Clone o repositório
git clone https://github.com/JoaoPalomares/app-projeto.git
cd app-projeto

# 2. Instale as dependências
flutter pub get

# 3. Rode o app
flutter run
```

Para rodar no navegador:

```bash
flutter run -d chrome
```

> 💡 **Dica:** ao alterar o registro de dependências (`dependencias.dart`) ou adicionar assets, faça um **hot restart** (ou pare e rode de novo). O hot reload não é suficiente.

### 🔥 Configuração do Firebase

O app usa o projeto Firebase `miaudote-ads`. O arquivo `lib/firebase_options.dart`, gerado pelo [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup), precisa estar presente para o app compilar. Se ele não estiver no seu clone, gere-o com:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=miaudote-ads
```

### 🔑 Acesso

Não há usuário de teste: crie sua conta na tela de **Cadastro** (a senha precisa ter ao menos 8 caracteres, com letra maiúscula, minúscula, número e símbolo) ou entre com a sua conta Google.

---

## 👥 Equipe

- **João Pedro Palomares**
- **Eduardo Cruz Junior**

**Instituição:** FATEC Ribeirão Preto · Análise e Desenvolvimento de Sistemas

---

## 📄 Contexto acadêmico

O Miaudote foi concebido em **Engenharia de Software II**, com documentação de arquitetura, requisitos não funcionais, tabelas de casos de uso, stack tecnológica e protótipo HTML interativo. Esta versão em Flutter é a implementação da proposta, desenvolvida como **projeto acadêmico** por dois alunos de ADS da FATEC Ribeirão Preto.

<div align="center">

Feito com 💛 e muito café por estudantes da FATEC Ribeirão Preto

</div>