import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_error.dart';

void handleResponseError(http.Response response) {
  final error = ApiError.fromJson(json.decode(response.body));
  throw Exception(error.message);
}