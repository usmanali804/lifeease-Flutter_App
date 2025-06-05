class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final Map<String, List<String>>? errors;

  ApiResponse({required this.success, this.data, this.message, this.errors});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json)? fromJson,
  ) {
    return ApiResponse(
      success: json['success'] as bool,
      data:
          json['data'] != null && fromJson != null
              ? fromJson(json['data'] as Map<String, dynamic>)
              : null,
      message: json['message'] as String?,
      errors:
          json['errors'] != null
              ? Map<String, List<String>>.from(
                (json['errors'] as Map).map(
                  (key, value) => MapEntry(
                    key as String,
                    (value as List).map((e) => e.toString()).toList(),
                  ),
                ),
              )
              : null,
    );
  }

  bool get hasError => !success;

  List<String>? getFieldErrors(String field) => errors?[field];

  String? get firstError {
    if (errors == null || errors!.isEmpty) return null;
    final firstField = errors!.entries.first;
    return firstField.value.isNotEmpty ? firstField.value.first : null;
  }
}

class PaginatedApiResponse<T> extends ApiResponse<List<T>> {
  final int total;
  final int page;
  final int limit;
  final bool hasMore;

  PaginatedApiResponse({
    required bool success,
    List<T>? data,
    String? message,
    Map<String, List<String>>? errors,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasMore,
  }) : super(success: success, data: data, message: message, errors: errors);

  factory PaginatedApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    final List<T> items =
        (json['data']['items'] as List)
            .map((item) => fromJson(item as Map<String, dynamic>))
            .toList();

    return PaginatedApiResponse(
      success: json['success'] as bool,
      data: items,
      message: json['message'] as String?,
      errors:
          json['errors'] != null
              ? Map<String, List<String>>.from(
                (json['errors'] as Map).map(
                  (key, value) => MapEntry(
                    key as String,
                    (value as List).map((e) => e.toString()).toList(),
                  ),
                ),
              )
              : null,
      total: json['data']['total'] as int,
      page: json['data']['page'] as int,
      limit: json['data']['limit'] as int,
      hasMore: json['data']['hasMore'] as bool,
    );
  }
}
