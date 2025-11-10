# Verby 

A comprehensive mobile workforce management application designed for hotel and cleaning service workers. Verby enables workers to manage daily operations, track work activities, perform quality checks, and synchronize data with a central server.

## 📱 Overview

Verby is a Flutter-based mobile application that provides:

- **Employee Authentication** - Secure login with Employee ID, PIN, and optional face recognition
- **Work Tracking** - Record check-in, check-out, pause-in, and pause-out actions
- **Room Management** - Select and manage room assignments (Depart and Restant rooms)
- **Quality Checks** - Perform detailed room inspections with checklists, comments, and photos
- **Offline Support** - Full functionality without internet connection with automatic sync
- **Face Recognition** - Biometric authentication using TensorFlow Lite and Google ML Kit
- **Multi-language** - Support for English and German

## ✨ Key Features

### Authentication & Security
- Employee ID and PIN verification
- Face recognition authentication (optional)
- Secure local data storage
- Encrypted communication with server

### Work Management
- Multiple operation types:
  - **STEWARDING** (Kitchen/Service operations)
  - **UNTERHALT** (Maintenance)
  - **GOUVERNANTE** (Room Control)
  - **RAUMPFLEGERIN** (Room Cleaning)
  - **BÜRO** (Office)
- Action recording (Check-in, Check-out, Pause-in, Pause-out)
- Room assignment tracking
- Volunteer assistance tracking

### Quality Control
- Room checklist system
- Photo documentation
- Comment and note-taking
- Status tracking (Red Card, Had Volunteer, Did Not Clean)

### Offline Capability
- Full offline functionality
- Local SQLite database
- Automatic data synchronization when online
- Visual connection status indicator

### Additional Features
- Kiosk mode (app pinning) for dedicated devices
- Haptic feedback and sound notifications
- Multi-language support (English/German)
- Settings and configuration management

## 🛠️ Tech Stack

- **Framework**: Flutter 3.8.1+
- **State Management**: Riverpod
- **Local Database**: SQLite (sqflite)
- **Face Recognition**: TensorFlow Lite, Google ML Kit
- **Networking**: Dio
- **Localization**: Easy Localization
- **Storage**: SharedPreferences, Flutter Secure Storage
- **Firebase**: Core, Crashlytics
- **Other**: Camera, Image Picker, Connectivity Plus

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Git
- Firebase account (for Crashlytics)

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd verby_flutter
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

1. Add your `google-services.json` file to `android/app/`
2. Configure Firebase for iOS in Xcode if needed
3. Ensure Firebase Crashlytics is properly set up

### 4. Configure API Endpoints

Update the API base URL and authentication tokens in the configuration files. See `AUTH_TOKEN_SETUP.md` for detailed instructions.

### 5. Run the Application

#### Android
```bash
flutter run
```

#### iOS
```bash
flutter run
```

Note: For iOS, you may need to:
- Run `pod install` in the `ios/` directory
- Configure signing in Xcode

## 📁 Project Structure

```
verby_flutter/
├── lib/
│   ├── core/              # Core utilities and constants
│   ├── data/              # Data layer (repositories, data sources)
│   ├── domain/            # Business logic layer
│   │   ├── entities/      # Domain models
│   │   ├── repositories/  # Repository interfaces
│   │   └── use_cases/     # Business use cases
│   ├── presentation/      # UI layer (screens, widgets)
│   ├── utils/             # Helper utilities
│   └── main.dart          # Application entry point
├── assets/
│   ├── images/            # Image assets
│   ├── langs/             # Localization files (en.json, de.json)
│   ├── svg/               # SVG icons
│   ├── animation/         # Lottie animations
│   ├── sound/             # Audio files
│   └── model/             # TensorFlow Lite model
├── android/               # Android-specific files
├── ios/                   # iOS-specific files
└── pubspec.yaml           # Dependencies and assets
```

## 🔧 Configuration

### Face Recognition Settings

Configure face recognition requirements in the Settings screen:
- Require Face ID for ALL employees
- Require for ONLY those with Face ID
- Set number of retry attempts

### Language Settings

The app supports English and German. Language can be changed in the Settings screen.

### Kiosk Mode

- **Android**: Uses Lock Task Mode (tap lock icon)
- **iOS**: Uses Guided Access (configure in iOS Settings)

## 🏗️ Building for Production

### Android

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## 📚 Key Dependencies

- `flutter_riverpod` - State management
- `sqflite` - Local database
- `dio` - HTTP client
- `google_mlkit_face_detection` - Face detection
- `tflite_flutter` - TensorFlow Lite integration
- `camera` - Camera functionality
- `connectivity_plus` - Network status
- `easy_localization` - Internationalization
- `flutter_secure_storage` - Secure storage
- `firebase_crashlytics` - Crash reporting

## 🔐 Security Features

- PIN verification for sensitive actions
- Face recognition for authentication
- Encrypted local storage
- Secure communication with server
- Password protection for settings

## 📖 Documentation

- [App Functionality Flow](APP_FUNCTIONALITY_FLOW.md) - Detailed documentation of app flows and features
- [Auth Token Setup](AUTH_TOKEN_SETUP.md) - Instructions for configuring authentication tokens

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is proprietary and confidential.

## 👥 Support

For issues, questions, or support, please contact the development team.

---

**Note**: This application is designed for internal use by hotel and cleaning service workers. Ensure proper authentication and security measures are in place before deployment.
