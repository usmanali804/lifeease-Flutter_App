/// Base model class that all data models should extend
abstract class BaseModel {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;

  BaseModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert model to JSON map
  Map<String, dynamic> toJson();

  /// Create a copy of the model with updated fields
  BaseModel copyWith();

  /// Override equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseModel && other.id == id;
  }

  /// Override hash code
  @override
  int get hashCode => id.hashCode;
}
