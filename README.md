<div align="center">

# 📰 BookShelf

### Agregador de Notícias para Estudantes Universitários

Desenvolvido para o grêmio estudantil do **ICEV — Instituto de Ensino Superior**

[![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0%2B-blue?logo=dart)](https://dart.dev)
[![SQLite](https://img.shields.io/badge/SQLite-Local-green?logo=sqlite)](https://www.sqlite.org)
[![GNews API](https://img.shields.io/badge/GNews-API-orange)](https://gnews.io)

</div>

---

## 📋 Sobre o Projeto

O **BookShelf** nasceu de uma necessidade real dos estudantes universitários: se informar de forma rápida, organizada e confiável, sem precisar navegar por redes sociais cheias de desinformação e entretenimento.

O app agrega manchetes de fontes jornalísticas reais via **GNews API**, organizadas por categoria, com busca por palavra-chave, filtro Brasil/Internacional, salvamento de artigos e leitura completa via WebView embutido.

---

## ✨ Funcionalidades

### 🔐 Autenticação
- Cadastro com nome, e-mail e senha
- Senha protegida com hash **SHA-256**
- Login com e-mail e senha
- **Auto-login** — entra direto se já estava logado
- Logout com limpeza total de sessão

### 🏠 Tela Principal
- Manchetes em cards com imagem, título, fonte e horário
- **6 categorias:** Geral, Tecnologia, Esportes, Ciência, Saúde, Entretenimento
- Busca por palavra-chave
- Switch 🇧🇷 **Brasil** / 🌍 **Internacional**
- Pull-to-refresh para atualizar
- Tratamento de erros (sem internet, limite de API, sem resultados)

### 📄 Tela de Leitura
- Imagem, título, descrição, fonte e data formatada
- Salvar/remover artigo com um toque
- **WebView embutido** — lê a matéria completa sem sair do app ✨

### 🔖 Tela de Salvos
- Artigos salvos organizados por não lidos primeiro
- **Checkbox** para marcar como lida
- Badge **"Não lida"** para artigos pendentes
- Contador de não lidos no topo
- Swipe para a esquerda para remover

---

## 🖼️ Telas do App

<div align="center">

<table>
  <tr>
    <td align="center"><b>Login</b></td>
    <td align="center"><b>Cadastro</b></td>
    <td align="center"><b>Notícias</b></td>
  </tr>
  <tr>
    <td><img src="screenshots/Tela de login.jpeg" width="220"/></td>
    <td><img src="screenshots/tela de cadastro.jpeg" width="220"/></td>
    <td><img src="screenshots/tela de noticias.jpeg" width="220"/></td>
  </tr>
  <tr>
    <td align="center"><b>Leitura</b></td>
    <td align="center"><b>Salvos</b></td>
    <td></td>
  </tr>
  <tr>
    <td><img src="screenshots/Informações sobre a noticia.jpeg" width="220"/></td>
    <td><img src="screenshots/tela de noticias salvas.jpeg" width="220"/></td>
    <td></td>
  </tr>
</table>

</div>

## 🗂️ Estrutura do Projeto

```
bookshelf/
├── lib/
│   ├── main.dart                       # Ponto de entrada do app
│   ├── models/
│   │   ├── user_model.dart             # Modelo de usuário
│   │   └── article_model.dart          # Modelo de artigo/notícia
│   ├── services/
│   │   ├── database_service.dart       # SQLite — usuários e salvos
│   │   ├── auth_service.dart           # Login, cadastro e autologin
│   │   ├── news_service.dart           # Integração com GNews API
│   │   └── preferences_service.dart   # Preferências com SharedPreferences
│   ├── screens/
│   │   ├── splash_screen.dart          # Tela inicial com autologin
│   │   ├── login_screen.dart           # Tela de login
│   │   ├── register_screen.dart        # Tela de cadastro
│   │   ├── home_screen.dart            # Tela principal com manchetes
│   │   ├── article_screen.dart         # Leitura da notícia + WebView
│   │   └── saved_screen.dart           # Artigos salvos
│   ├── widgets/
│   │   ├── article_card.dart           # Card de notícia reutilizável
│   │   └── category_chips.dart         # Chips de categoria horizontais
│   └── utils/
│       └── app_theme.dart              # Tema, cores e estilos globais
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml         # Permissões Android
└── pubspec.yaml                        # Dependências do projeto
```

---

## 🚀 Como Rodar o Projeto

### Pré-requisitos

Antes de começar, instale:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) **>= 3.0.0**
- [Android Studio](https://developer.android.com/studio) ou [VS Code](https://code.visualstudio.com/) com extensão Flutter
- Um celular Android **ou** emulador Android
- Conta gratuita na [GNews API](https://gnews.io/)

Verifique sua instalação:
```bash
flutter doctor
```

---

### ▶️ Opção 1 — Celular Android (Recomendado)

**1. Ativar Depuração USB no celular:**
- Vá em **Configurações → Sobre o telefone**
- Toque **7 vezes** em "Número da versão"
- Vá em **Configurações → Opções do desenvolvedor**
- Ative **Depuração USB**
- Conecte o celular via USB e toque em **Permitir** quando aparecer a janela

**2. Clonar o repositório:**
```bash
git clone https://github.com/WalterdesJunior/BOOKSHELF.git
cd BOOKSHELF
```

**3. Configurar a API Key:**

Acesse [gnews.io](https://gnews.io/), crie uma conta e copie sua chave.

Abra `lib/services/news_service.dart` e substitua:
```dart
static const String _apiKey = 'SUA_CHAVE_AQUI';
```

**4. Instalar dependências:**
```bash
flutter pub get
```

**5. Verificar se o celular foi detectado:**
```bash
flutter devices
```

**6. Rodar:**
```bash
flutter run
```

---

### ▶️ Opção 2 — Emulador Android

**1. Abrir o Android Studio → Tools → Device Manager → Create Device**

Escolha um modelo (ex: Pixel 6), selecione API 33 e clique em Finish.

**2. Iniciar o emulador:**
```bash
flutter emulators --launch <nome_do_emulador>
```

**3. Rodar:**
```bash
flutter run
```

---

### ▶️ Opção 3 — Linux Desktop

> ⚠️ O SQLite e WebView podem ter comportamento diferente no Linux.

**Instalar dependências do sistema:**
```bash
sudo apt update && sudo apt install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev lld
```

**Rodar:**
```bash
flutter run -d linux
```

---

### ▶️ Opção 4 — Gerar APK

Para gerar um `.apk` e instalar diretamente no celular:

```bash
flutter build apk --release
```

O arquivo será gerado em:
```
build/app/outputs/flutter-apk/app-release.apk
```

Transfira para o celular via USB ou WhatsApp e instale normalmente.

---

## 📦 Dependências

| Pacote | Versão | Para que serve |
|---|---|---|
| `http` | ^1.2.1 | Requisições para a GNews API |
| `sqflite` | ^2.3.2 | Banco de dados SQLite local |
| `path` | ^1.9.0 | Localizar o banco no dispositivo |
| `shared_preferences` | ^2.2.3 | Salvar preferências do usuário |
| `webview_flutter` | ^4.7.0 | Abrir matérias dentro do app |
| `cached_network_image` | ^3.3.1 | Carregar e cachear imagens |
| `crypto` | ^3.0.3 | Criptografar senhas com SHA-256 |
| `intl` | ^0.19.0 | Formatar datas em pt_BR |

---

## 🗄️ Banco de Dados

O app usa **SQLite local** — o banco fica salvo no próprio celular, sem servidor externo.

### Tabela `users`
| Campo | Tipo | Descrição |
|---|---|---|
| id | INTEGER | Chave primária |
| name | TEXT | Nome do usuário |
| email | TEXT | E-mail (único) |
| password_hash | TEXT | Senha em SHA-256 |
| created_at | TEXT | Data de cadastro |

### Tabela `saved_articles`
| Campo | Tipo | Descrição |
|---|---|---|
| id | INTEGER | Chave primária |
| title | TEXT | Título da notícia |
| description | TEXT | Resumo |
| url | TEXT | Link (único) |
| image_url | TEXT | URL da imagem |
| source | TEXT | Nome da fonte |
| published_at | TEXT | Data de publicação |
| category | TEXT | Categoria |
| is_read | INTEGER | 0 = não lida, 1 = lida |
| is_saved | INTEGER | 0 = não salva, 1 = salva |

> **Importante:** o banco é local por dispositivo. Cada celular tem seus próprios dados — não há sincronização entre aparelhos.

---

## 🌐 GNews API

| Item | Detalhe |
|---|---|
| Site | [gnews.io](https://gnews.io/) |
| Plano gratuito | 100 requisições/dia |
| Autenticação | API Key simples (sem OAuth) |

**Endpoints utilizados:**
```
# Manchetes por categoria
GET https://gnews.io/api/v4/top-headlines?category=technology&lang=pt&country=br&max=10&apikey=KEY

# Busca por palavra-chave  
GET https://gnews.io/api/v4/search?q=vestibular&lang=pt&max=10&apikey=KEY
```

---

## 🎨 Paleta de Cores

| Nome | Hex |
|---|---|
| Primary (AppBar) | `#1A1A2E` |
| Accent (roxo) | `#6C63FF` |
| Background | `#F5F6FA` |
| Success | `#10B981` |
| Error | `#EF4444` |
| Text Secondary | `#6B7280` |

---

## 🛠️ Solução de Problemas

**❌ "Sem conexão com a internet" dentro do app**
→ Verifique se o `AndroidManifest.xml` tem `<uses-permission android:name="android.permission.INTERNET"/>`

**❌ "Limite de requisições atingido"**
→ O plano gratuito permite 100 req/dia. Aguarde até o dia seguinte.

**❌ WebView não carrega alguns sites**
→ Verifique se o `AndroidManifest.xml` tem `android:usesCleartextTraffic="true"`

**❌ Erro de build**
```bash
flutter clean && flutter pub get && flutter run
```

**❌ Celular não aparece em `flutter devices`**
→ Verifique se a Depuração USB está ativada e confirme a janela de permissão no celular.

**❌ Erro `ld.lld not found` no Linux**
```bash
sudo apt install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev lld
```

---

## 👨‍💻 Autor

**Walterdes Junior**
[github.com/WalterdesJunior](https://github.com/WalterdesJunior)

**Paulo Henrique**
[github.com/PauloHenrique](https://github.com/Pauloohenri)

**Livio Júnior**
[github.com/Livio038] (https://github.com/Livio038) 


---

<div align="center">
Desenvolvido para fins acadêmicos no <strong>ICEV — Instituto de Ensino Superior</strong><br><br>
</div>
