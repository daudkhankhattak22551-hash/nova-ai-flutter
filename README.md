# Nova AI

Nova AI is a professional, production-ready AI assistant mobile application built with the Flutter framework. It offers a premium, modern user experience powered by state-of-the-art artificial intelligence models.

## Overview

Nova AI is designed to be a comprehensive personal assistant, integrating advanced natural language processing and creative tools into a single, cohesive ecosystem. The application provides users with an intuitive "Dark-First" dashboard to access a suite of AI capabilities, from real-time streaming chat to sophisticated image generation. With a focus on performance, security, and aesthetics, Nova AI demonstrates the potential of cross-platform mobile development in the AI era.

## Features

- **Smart AI Chat**: Context-aware, real-time streaming conversations powered by Llama 3.3 (via Groq Cloud). Supports rich Markdown rendering and interactive code blocks.
- **Vision AI (Image Generator)**: High-quality image generation using Pollinations AI, with customizable styles, aspect ratios, and sample controls.
- **Persistent Account System**: A robust, locally persistent authentication system allowing users to manage their profiles, bios, and personalized settings.
- **Premium Experience**: A complete subscription-state system that unlocks advanced features and elite AI models across the application.
- **Voice Assistant**: Hands-free interactions through a dedicated voice interface for a more natural assistant experience.
- **Comprehensive History**: Full management of previous conversations with search, rename, and delete functionalities powered by a local NoSQL database.
- **Advanced AI Tuning**: Granular control over the AI's "personality" through temperature adjustment, model selection, and response style preferences.
- **Polished UI/UX**: Sophisticated design featuring glassmorphism, smooth entrance animations, and adaptive dark/light mode support.

## Screenshots

| Home Dashboard | Smart AI Chat | Vision AI | Voice Assistant |
| :---: | :---: | :---: | :---: |
| ![Home](screenshots/home.png) | ![Chat](screenshots/chat.png) | ![Vision](screenshots/image-generator.png) | ![Voice](screenshots/voice-assistant.png) |

| Chat History | User Profile | App Settings | Premium Plan |
| :---: | :---: | :---: | :---: |
| ![History](screenshots/history.png) | ![Profile](screenshots/profile.png) | ![Settings](screenshots/settings.png) | ![Premium](screenshots/premium.png) |

## Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (Dart)
- **State Management**: [GetX](https://pub.dev/packages/get) & ChangeNotifier
- **Local Database**: [Hive](https://pub.dev/packages/hive) (High-performance NoSQL)
- **AI Integrations**:
  - [Groq Cloud API](https://groq.com/) (Llama 3.3 70B, Llama 3 8B)
  - [Pollinations AI](https://pollinations.ai/) (Vision & Creativity)
- **Typography**: [Google Fonts (Poppins)](https://fonts.google.com/specimen/Poppins)
- **Networking**: [http](https://pub.dev/packages/http)
- **Core Packages**: `flutter_markdown`, `share_plus`, `path_provider`, `gal`, `uuid`

## Project Structure

- `lib/core`: Centralized logic for themes, app routes, constants, and secure configurations.
- `lib/models`: Structured data classes for Users, Chat Messages, and History.
- `lib/screens`: Modular UI implementations for all primary and secondary views.
- `lib/services`: Business logic layer handling AI communications, authentication, and database operations.
- `lib/widgets`: Reusable, custom-styled UI components including premium wrappers and navigators.
- `lib/controllers`: State logic for application-wide flow control.

## Getting Started

### Prerequisites

- Flutter SDK (Stable Channel)
- Dart SDK
- Android Studio or VS Code

### Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/[your-username]/nova-ai.git
    cd nova-ai
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Configure API Keys**:
    Nova AI uses secure environment variables for API configuration. You must provide your own keys during build or run.

    ```bash
    flutter run \
      --dart-define=GROQ_API_KEY=your_groq_key_here \
      --dart-define=GEMINI_API_KEY=your_gemini_key_here \
      --dart-define=POLLINATIONS_API_KEY=your_pollinations_key_here
    ```

## Security

Security is a priority. This project follows industry best practices for key management:
- **No hardcoded secrets**: All API keys are injected at compile-time via `--dart-define`.
- **Local Persistence**: User credentials and history are stored securely on the device using Hive's encrypted-compatible storage options.
- **Privacy**: No personal data is transmitted to third parties except for the direct prompts sent to configured AI providers.

## Developer

**Daud Khan**  
Flutter Developer

- [GitHub](https://github.com/[your-username])
- [LinkedIn](https://linkedin.com/in/[your-profile])
- [Email](mailto:[your-email@example.com])

## Project Status

**Current Version**: 1.0.2  
**Status**: Active Development. The application is fully functional with core assistant capabilities. Future updates will focus on cloud sync integration and expanded multi-modal AI support.
