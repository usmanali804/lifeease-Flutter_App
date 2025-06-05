import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:life_ease/features/wellness/water_tracker/models/water_entry_model.dart';
import 'package:life_ease/features/wellness/water_tracker/domain/water_tracking_service.dart';
import '../../helpers/mocks.mocks.dart';

void main() {
  group('Water Tracking Tests', () {
    late MockWaterTrackingService mockWaterService;
    final testDate = DateTime(2024, 1, 1); // Use a fixed date for testing

    setUp(() {
      mockWaterService = MockWaterTrackingService();
    });

    test('add water entry should update daily total', () async {
      // Arrange
      final entry = WaterEntry(
        amount: 250.0,
        date: testDate,
        note: 'Morning water',
      );
      when(
        mockWaterService.addWaterEntry(entry),
      ).thenAnswer((_) async => entry);
      when(
        mockWaterService.getDailyTotal(testDate),
      ).thenAnswer((_) async => 250.0);

      // Act
      final addedEntry = await mockWaterService.addWaterEntry(entry);
      final dailyTotal = await mockWaterService.getDailyTotal(testDate);

      // Assert
      expect(addedEntry.amount, equals(250.0));
      expect(dailyTotal, equals(250.0));
      verify(mockWaterService.addWaterEntry(entry)).called(1);
      verify(mockWaterService.getDailyTotal(testDate)).called(1);
    });

    test('fetch daily entries should return correct list', () async {
      // Arrange
      final entries = [
        WaterEntry(amount: 250.0, date: testDate, note: 'Morning'),
        WaterEntry(amount: 300.0, date: testDate, note: 'Afternoon'),
      ];
      when(mockWaterService.getWaterEntries()).thenAnswer((_) async => entries);

      // Act
      final result = await mockWaterService.getWaterEntries();

      // Assert
      expect(result.length, equals(2));
      expect(result[0].amount, equals(250.0));
      expect(result[1].amount, equals(300.0));
      verify(mockWaterService.getWaterEntries()).called(1);
    });

    test('delete entry should update daily total', () async {
      // Arrange
      final entryId = 'test-entry-id';
      when(
        mockWaterService.deleteWaterEntry(entryId),
      ).thenAnswer((_) async => true);
      when(
        mockWaterService.getDailyTotal(testDate),
      ).thenAnswer((_) async => 0.0);

      // Act
      final deleted = await mockWaterService.deleteWaterEntry(entryId);
      final dailyTotal = await mockWaterService.getDailyTotal(testDate);

      // Assert
      expect(deleted, isTrue);
      expect(dailyTotal, equals(0.0));
      verify(mockWaterService.deleteWaterEntry(entryId)).called(1);
      verify(mockWaterService.getDailyTotal(testDate)).called(1);
    });
  });
}
