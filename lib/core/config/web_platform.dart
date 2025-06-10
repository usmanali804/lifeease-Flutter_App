/// A web-compatible Platform implementation
class Platform {
  /// Web environment doesn't support environment variables
  static Map<String, String> get environment => {};
}
