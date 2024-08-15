import 'dart:convert';

import 'package:advanced_flutter/domain/entities/domain_error.dart';
import 'package:advanced_flutter/infra/api/client/http_get_client.dart';
import 'package:advanced_flutter/infra/types/json.dart';
import 'package:dartx/dartx_io.dart';
import 'package:http/http.dart';

final class HttpAdapter implements HttpGetClient {
  final Client client;

  const HttpAdapter({required this.client});

  @override
  Future<T> get<T>(
    String url, {
    Map<String, String>? headers,
    Map<String, String?>? params,
    Map<String, String>? qs,
  }) async {
    var response = await client.get(
      _buildUri(url: url, params: params, qs: qs),
      headers: _buildHeaders(headers),
    );

    return handleResponse<T>(response);
  }

  Map<String, String> _buildHeaders(Map<String, String>? headers) {
    const Map<String, String> defaultHeaders = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };
    return (headers ?? {})..addAll(defaultHeaders);
  }

  T handleResponse<T>(Response response) {
    switch (response.statusCode) {
      case 200:
        if (response.body.isEmpty) throw DomainError.unexpected;
        var data = jsonDecode(response.body);
        return (T == JsonArr) ? data.map<Json>((e) => e as Json).toList() : data;
      case 401:
        throw DomainError.sessionExpired;
      default:
        throw DomainError.unexpected;
    }
  }

  Uri _buildUri({required String url, Map<String, String?>? params, Map<String, String>? qs}) {
    params?.forEach((k, v) => url = url.replaceFirst(":$k", v ?? ""));
    url = url.removeSuffix("/");
    if (qs != null) url += "?${qs.entries.map((e) => "${e.key}=${e.value}").join("&")}";
    return Uri.parse(url);
  }
}
