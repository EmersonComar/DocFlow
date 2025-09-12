# DocFlow

Um gerenciador de templates e anotações construído com Flutter, focado em uma interface limpa, moderna e eficiente.

![DocFlow Screenshot](https://i.imgur.com/O4q5e5f.png)

## 🚀 Sobre o Projeto

O DocFlow foi projetado para ajudar desenvolvedores, escritores e profissionais a armazenar e gerenciar snippets de código, respostas prontas, anotações e qualquer tipo de texto reutilizável. Com uma interface intuitiva e recursos de busca e filtragem, encontrar o que você precisa nunca foi tão rápido.

## ✨ Recursos

- **Interface Moderna com Material 3:** Um design limpo e responsivo que segue as diretrizes mais recentes do Google.
- **Temas Claro e Escuro:** Alterne facilmente entre os modos para melhor conforto visual.
- **Gerenciamento Completo de Templates:** Crie, edite e delete templates com facilidade através de um diálogo intuitivo.
- **Busca e Filtragem:** Encontre templates rapidamente pesquisando por título/conteúdo ou filtrando por múltiplas tags.
- **Cards Expansíveis:** Visualize um trecho do conteúdo ou expanda o card com um clique para ver o texto completo.
- **Copiar com Um Clique:** O botão "Copiar" permite que você envie o conteúdo do template para a área de transferência instantaneamente.
- **Banco de Dados Local:** Seus dados são armazenados de forma segura e persistente em um banco de dados SQLite local.

## 🛠️ Tecnologias Utilizadas

- **Framework:** [Flutter](https://flutter.dev/)
- **Gerenciamento de Estado:** [Provider](https://pub.dev/packages/provider)
- **Banco de Dados:** [sqflite](https://pub.dev/packages/sqflite) com [sqflite_common_ffi](https://pub.dev/packages/sqflite_common_ffi) para suporte desktop (Windows, macOS, Linux).
- **Design:** [Material 3](https://m3.material.io/)

## ▶️ Como Começar

Siga as instruções abaixo para obter uma cópia local do projeto e executá-la.

### Pré-requisitos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (versão 3.x ou superior)
- Um editor de código como [VS Code](https://code.visualstudio.com/) ou [Android Studio](https://developer.android.com/studio).

### Instalação e Execução

1.  **Clone o repositório:**
    ```sh
    git clone https://github.com/EmersonComar/DocFlow.git
    cd DocFlow
    ```

2.  **Instale as dependências:**
    ```sh
    flutter pub get
    ```

3.  **Execute o aplicativo:**
    ```sh
    flutter run
    ```

O aplicativo deve iniciar no seu emulador, navegador ou dispositivo desktop conectado.