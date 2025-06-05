# Life Ease 🌟

<div align="center">
    <img src="assets/app_icon.png" alt="Life Ease Logo" width="200"/>
</div>

Life Ease is a comprehensive Flutter application designed to make everyday tasks easier and more accessible. With features ranging from task management to communication tools, Life Ease serves as your personal assistant in managing daily activities.

![Flutter Version](https://img.shields.io/badge/Flutter-3.x-blue)
![Dart Version](https://img.shields.io/badge/Dart-3.x-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-lightgrey)

## 📱 Features

- **Task Management** - Create, organize, and track your daily tasks
- **Chat Communication** - Built-in messaging system for seamless communication
- **Water Tracking** - Monitor your daily water intake
- **Multi-language Support** - Available in English, Arabic, Hindi, and Urdu
- **Speech-to-Text** - Voice input support for easy task creation
- **Text-to-Speech** - Audio output for better accessibility
- **Image Recognition** - ML-powered text recognition from images
- **Secure Storage** - Encrypted storage for sensitive information
- **Cross-platform Support** - Works on Android, iOS, Windows, macOS, Linux, and Web

## 🔧 Technical Stack

- **Frontend**: Flutter
- **Backend**: Node.js
- **Database**: MongoDB (configured in backend)
- **State Management**: Provider/Bloc (to be specified)
- **Authentication**: JWT-based auth system
- **Storage**: Secure local storage with flutter_secure_storage
- **API Integration**: REST APIs with WebSocket support

## 🛠️ Core Dependencies

- `connectivity_plus`: Network connectivity management
- `flutter_secure_storage`: Secure data storage
- `google_mlkit_text_recognition`: Text recognition from images
- `flutter_tts`: Text-to-speech functionality
- `speech_to_text`: Voice input processing
- `image_picker`: Image selection and capture
- `share_plus`: Content sharing capabilities
- `path_provider`: File system access
- `shared_preferences`: Local data persistence

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (Latest Version)
- Node.js (for backend)
- MongoDB
- Android Studio/VS Code with Flutter plugins

### Installation

1. Clone the repository:
```bash
git clone [repository-url]
```

2. Install Frontend Dependencies:
```bash
flutter pub get
```

3. Setup Backend:
```bash
cd backend
npm install
```

4. Configure Environment:
   - Create `.env` file in the backend directory
   - Set up necessary environment variables (DB_URL, JWT_SECRET, etc.)

5. Run the Application:
```bash
# Start Backend Server
cd backend
npm start

# Run Flutter Application
flutter run
```

## 🌐 Environment Setup

### Backend Configuration
The backend server requires the following environment variables:
```env
PORT=3000
MONGODB_URI=your_mongodb_uri
JWT_SECRET=your_jwt_secret
```

### Frontend Configuration
Update the backend URL in the Flutter application:
```dart
// lib/config/config.dart
const String apiBaseUrl = 'your_backend_url';
```

## 📁 Project Structure

```
lib/
├── core/         # Core functionality and utilities
├── data/         # Data layer (models, repositories)
├── features/     # Feature modules
├── services/     # Service classes
├── shared/       # Shared components and widgets
├── home_page.dart # Main home page
└── main.dart     # Application entry point

backend/
├── config/
│   ├── config.js        # App configuration
│   ├── database.js      # Database setup
│   └── websocket.js     # WebSocket configuration
├── middleware/
│   ├── auth.middleware.js
│   ├── database.middleware.js
│   ├── error.middleware.js
│   ├── rate-limiter.middleware.js
│   └── validation.middleware.js
├── models/
│   ├── message.model.js # Chat message model
│   ├── task.model.js    # Task management model
│   ├── user.model.js    # User model
│   └── water-entry.model.js # Water tracking model
├── routes/
│   ├── auth.routes.js   # Authentication routes
│   ├── chat.routes.js   # Chat functionality
│   ├── task.routes.js   # Task management
│   ├── user.routes.js   # User operations
│   └── water.routes.js  # Water tracking
└── server.js     # Server entry point

assets/
└── translations/  # Localization files
    ├── ar.json   # Arabic
    ├── en.json   # English
    ├── hi.json   # Hindi
    └── ur.json   # Urdu
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🛡️ Security

Life Ease takes security seriously. We implement:

- JWT-based authentication
- Encrypted data storage using flutter_secure_storage
- Rate limiting on API endpoints
- Input validation and sanitization
- Secure WebSocket connections

## 👥 Authors

- Your Name - *Initial work* - [YourGitHub](https://github.com/usmanali804)

## 🌍 Localization

The app supports multiple languages out of the box:
- English (en)
- Arabic (ar)
- Hindi (hi)
- Urdu (ur)

To add a new language, add a JSON file in `assets/translations/`.

## 🙏 Acknowledgments

- Thanks to all contributors who have helped this project grow
- Flutter team for the amazing framework
- The open-source community for various packages used in this project