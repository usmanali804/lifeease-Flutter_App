class Environment {
  static final Map<String, dynamic> _config = {
    'development': {
      'apiUrl': 'http://localhost:3000', // Default development API URL
    },
    'production': {
      'apiUrl':
          'https://api.life-ease.com', // Replace with your production API URL
    },
  };

  static final String _environment = const String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static dynamic get(String key) {
    try {
      return _config[_environment][key];
    } catch (e) {
      throw Exception('Environment key $key not found');
    }
  }

  static bool isDevelopment() => _environment == 'development';
  static bool isProduction() => _environment == 'production';
}
