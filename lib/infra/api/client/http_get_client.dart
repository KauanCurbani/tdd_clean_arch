import 'package:advanced_flutter/infra/types/json.dart';

abstract interface class HttpGetClient {
  Future<dynamic> get(
    String url, {
    Json? headers,
    Json? params,
    Json? qs,
  });
}
