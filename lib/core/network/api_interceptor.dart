import 'package:dio/dio.dart';
import '../utils/token_manager.dart';
import 'api_endpoints.dart';

class ApiInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add token to request if available
    final token = await TokenManager.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Add common headers
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 &&
        err.requestOptions.path != ApiEndpoints.refreshToken) {
      // Token expired, try to refresh
      final refreshToken = await TokenManager.getRefreshToken();
      if (refreshToken != null) {
        try {
          // Create a new Dio instance to avoid interceptor loop
          final dio = Dio();
          final response = await dio.post(
            ApiEndpoints.refreshToken,
            data: {'refreshToken': refreshToken},
          );

          if (response.statusCode == 200) {
            // Save new tokens
            await TokenManager.saveToken(response.data['accessToken']);
            await TokenManager.saveRefreshToken(response.data['refreshToken']);

            // Retry original request
            final opts = err.requestOptions;
            opts.headers['Authorization'] =
                'Bearer ${response.data['accessToken']}';

            final newResponse = await dio.fetch(opts);
            return handler.resolve(newResponse);
          }
        } catch (e) {
          // Refresh token failed, clear tokens and proceed with error
          await TokenManager.clearToken();
        }
      }
    }
    return handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Handle any common response processing here
    return handler.next(response);
  }
}
