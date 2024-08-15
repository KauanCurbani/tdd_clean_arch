abstract class HttpGetClient {
  Future<T> get<T>(
    String url, {
    Map<String, String>? headers,
    Map<String, String?>? params,
    Map<String, String>? qs,
  });
}
