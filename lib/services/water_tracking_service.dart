import '../features/wellness/water_tracker/models/water_entry_model.dart';

abstract class WaterTrackingService {
  Future<List<WaterEntry>> getWaterEntries();
  Future<WaterEntry> addWaterEntry(WaterEntry entry);
  Future<bool> deleteWaterEntry(String entryId);
  Future<WaterEntry> updateWaterEntry(WaterEntry entry);
  Future<double> getDailyTotal(DateTime date);
}
