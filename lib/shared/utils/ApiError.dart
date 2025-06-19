class ApiError {
  final String message;
  final int statusCode;
  final String? path;
  final List<String>? details;

  ApiError({
    required this.message,
    required this.statusCode,
    this.path,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['message'] ?? 'Error desconocido',
      statusCode: json['statusCode'] ?? 500,
      path: json['path'],
      details: json['details'] != null ? List<String>.from(json['details']) : null,
    );
  }
}