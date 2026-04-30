# NextStep

A comprehensive career guidance and internship placement application designed specifically for computing undergraduates.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

## Overview

**NextStep** aims to bridge the gap between computing students and the industry by providing a streamlined platform for career path discovery, CV evaluation, and internship hunting. Using AI-driven insights, NextStep analyzes a student's CV to recommend suitable career paths and provides an evaluation score, helping undergraduates prepare for their professional journey.

## Features

- **User Authentication**: Secure login and registration using Firebase Authentication.
- **AI-Powered CV Evaluation**: Upload your CV (PDF) and get an AI-generated evaluation score and summary.
- **Career Path Recommendations**: Receive tailored career path suggestions based on your skills and CV analysis.
- **Internship Discovery**: Browse, search, and apply for computing internships directly from the app.
- **Profile Management**: Maintain an up-to-date professional profile with skills, experiences, and academic details.
- **Modern UI/UX**: Built with a sleek, responsive design featuring smooth animations (`flutter_animate`), intuitive navigation, and beautiful typography (`google_fonts`).

## Tech Stack & Architecture

- **Framework**: Flutter
- **State Management**: Provider
- **Backend/Database**: Firebase (Auth, Cloud Firestore, Storage)
- **AI Integration**: Groq API (via `http` and `flutter_dotenv`)
- **Key Packages**:
  - `file_picker` & `syncfusion_flutter_pdf` for document handling.
  - `shimmer` & `percent_indicator` for loading states and data visualization.
  - `cached_network_image` for optimized image rendering.

## Setup Instructions

If you have just cloned this project, follow these steps to get it running on your local machine.

### 1. Prerequisites

- Flutter SDK (v3.11.0 or higher)
- Dart SDK
- Android Studio / Xcode for emulators
- A Firebase project configured for Android/iOS (the `firebase_options.dart` should be generated if not present)

### 2. Environment Variables

This project relies on environment variables for external APIs (like the AI CV evaluation features).

1. Create a `.env` file in the root directory by copying the provided example file:
   ```bash
   cp .env.example .env
   ```
2. Open the newly created `.env` file and add your `GROK_API_KEY`:
   ```env
   GROK_API_KEY="your_actual_api_key_here"
   ```
   *(If you just want to build the UI and don't need AI features, you can leave the value empty).*

### 3. Install Dependencies

Fetch all the required Flutter packages:
```bash
flutter pub get
```

### 4. Run the Application

Launch the app on your connected device or emulator:
```bash
flutter run
```

## Project Structure

```text
lib/
├── core/           # Theming, constants, and global utilities
├── models/         # Data classes (User, Internship, CareerPath)
├── providers/      # State management (Auth, Internship providers)
├── screens/        # UI screens grouped by feature (Auth, CV, Home, AI Features, etc.)
├── services/       # External APIs and Firebase integrations (AI, Jobs, Storage, Users)
├── widgets/        # Reusable UI components
└── main.dart       # App entry point
```

## Contributing

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request
