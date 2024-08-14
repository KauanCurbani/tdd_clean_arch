abstract class HttpGetClient {
  Future<T> get<T>({required String url, Map<String, String>? params});
}