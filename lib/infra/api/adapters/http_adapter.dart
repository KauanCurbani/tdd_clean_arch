import 'dart:convert';

import 'package:advanced_flutter/domain/entities/errors.dart';
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
    Json? headers,
    Json? params,
    Map<String, String>? qs,
  }) async {
    var response = await client.get(
      _buildUri(url: url, params: params, qs: qs),
      headers: _buildHeaders(headers),
    );

    return handleResponse<T>(response);
  }

  Map<String, String> _buildHeaders(Json? headers) {
    Map<String, String> defaultHeaders = {"Content-Type": "application/json", "Accept": "application/json"};
    defaultHeaders.addAll({for (final key in (headers ?? {}).keys) key: headers![key].toString()});
    return defaultHeaders;
  }

  T handleResponse<T>(Response response) {
    switch (response.statusCode) {
      case 200:
        if (response.body.isEmpty) throw UnexpectedError();
        var data = jsonDecode(response.body);
        return (T == JsonArr) ? data.map<Json>((e) => e as Json).toList() : data;
      case 401:
        throw SessionExpiredError();
      default:
        throw UnexpectedError();
    }
  }

  Uri _buildUri({required String url, Json? params, Map<String, String>? qs}) {
    params?.forEach((k, v) => url = url.replaceFirst(":$k", v?.toString() ?? ""));
    url = url.removeSuffix("/");
    if (qs != null) url += "?${qs.entries.map((e) => "${e.key}=${e.value}").join("&")}";
    return Uri.parse(url);
  }
}
