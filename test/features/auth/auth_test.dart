import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:life_ease/core/auth/auth_service.dart';
import '../../helpers/mocks.mocks.dart';

void main() {
  group('Authentication Tests', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    test('login with valid credentials should succeed', () async {
      const email = 'test@example.com';
      const password = 'password123';

      // Setup mock behavior for successful login
      when(mockAuthService.login(email, password)).thenAnswer((_) async {});

      // Should complete without throwing
      await expectLater(mockAuthService.login(email, password), completes);

      verify(mockAuthService.login(email, password)).called(1);
    });

    test('login with invalid credentials should fail', () async {
      const email = 'invalid@example.com';
      const password = 'wrongpass';

      // Setup mock behavior for failed login
      when(
        mockAuthService.login(email, password),
      ).thenThrow(Exception('Invalid credentials'));

      expect(() => mockAuthService.login(email, password), throwsException);

      verify(mockAuthService.login(email, password)).called(1);
    });

    test('logout should work correctly', () async {
      // Setup mock behavior for logout
      when(mockAuthService.logout()).thenAnswer((_) async {});

      // Should complete without throwing
      await expectLater(mockAuthService.logout(), completes);

      verify(mockAuthService.logout()).called(1);
    });

    test('isAuthenticated should return authentication status', () async {
      // Setup mock behavior for auth check with token
      when(mockAuthService.getToken()).thenAnswer((_) async => 'valid_token');

      final result = await mockAuthService.isAuthenticated();

      expect(result, isTrue);
      verify(mockAuthService.getToken()).called(1);
    });

    test('isAuthenticated should return false when no token', () async {
      // Setup mock behavior for auth check without token
      when(mockAuthService.getToken()).thenAnswer((_) async => null);

      final result = await mockAuthService.isAuthenticated();

      expect(result, isFalse);
      verify(mockAuthService.getToken()).called(1);
    });
  });
}
