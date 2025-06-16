class ErrorResponse {
  final String error;
  final String message;

  ErrorResponse({required this.error, required this.message});

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(error: json['error'], message: json['message']);
  }
}
