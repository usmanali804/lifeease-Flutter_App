class RateLimiter {
  final Duration window;
  final int maxRequests;
  final Map<String, _RateLimit> _limits = {};

  RateLimiter({
    this.window = const Duration(minutes: 1),
    this.maxRequests = 60,
  });

  bool shouldAllowRequest(String key) {
    final now = DateTime.now();
    _cleanupExpired(now);

    if (!_limits.containsKey(key)) {
      _limits[key] = _RateLimit(now, 1);
      return true;
    }

    final limit = _limits[key]!;
    if (now.difference(limit.windowStart) >= window) {
      _limits[key] = _RateLimit(now, 1);
      return true;
    }

    if (limit.requestCount < maxRequests) {
      limit.requestCount++;
      return true;
    }

    return false;
  }

  void _cleanupExpired(DateTime now) {
    _limits.removeWhere(
      (key, limit) => now.difference(limit.windowStart) >= window,
    );
  }
}

class _RateLimit {
  final DateTime windowStart;
  int requestCount;

  _RateLimit(this.windowStart, this.requestCount);
}
