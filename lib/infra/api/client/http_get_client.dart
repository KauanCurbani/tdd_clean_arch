import 'package:advanced_flutter/infra/types/json.dart';

abstract interface class HttpGetClient {
  Future<T> get<T>(
    String url, {
    Json? headers,
    Json? params,
    Json? qs,
  });
}
