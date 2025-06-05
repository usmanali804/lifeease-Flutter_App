abstract class AuthService {
  Future<String?> login(String email, String password);
  Future<bool> register(String email, String password, String name);
  Future<bool> logout();
  Future<String?> refreshToken();
  Future<bool> isAuthenticated();
}
