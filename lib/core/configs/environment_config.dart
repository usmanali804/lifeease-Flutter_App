/// Environment configuration for different build variants
class Environment {
  static const String dev = 'dev';
  static const String staging = 'staging';
  static const String prod = 'prod';

  static const String current = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: dev,
  );

  static final Map<String, dynamic> config = {
    dev: {
      'apiUrl': 'http://localhost:3000/api',
      'enableLogging': true,
      'analyticsEnabled': false,
    },
    staging: {
      'apiUrl': 'https://staging-api.lifeease.com',
      'enableLogging': true,
      'analyticsEnabled': true,
    },
    prod: {
      'apiUrl': 'https://api.lifeease.com',
      'enableLogging': false,
      'analyticsEnabled': true,
    },
  };

  static dynamic get(String key) => config[current][key];

  static bool get isDev => current == dev;
  static bool get isStaging => current == staging;
  static bool get isProd => current == prod;
}
