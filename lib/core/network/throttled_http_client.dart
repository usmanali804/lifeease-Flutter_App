import 'package:http/http.dart' as http;

class ThrottledHttpClient extends http.BaseClient {
  final Duration throttleDuration;
  final http.Client _inner;
  DateTime? _lastRequestTime;

  ThrottledHttpClient({
    this.throttleDuration = const Duration(milliseconds: 100),
    http.Client? inner,
  }) : _inner = inner ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (_lastRequestTime != null) {
      final elapsed = DateTime.now().difference(_lastRequestTime!);
      if (elapsed < throttleDuration) {
        await Future.delayed(throttleDuration - elapsed);
      }
    }
    _lastRequestTime = DateTime.now();
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
