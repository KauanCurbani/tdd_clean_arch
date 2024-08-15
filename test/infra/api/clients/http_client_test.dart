import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

class HttpClient {
  final Client client;
  final Map<String, String> _defaultHeaders = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  HttpClient({required this.client});

  Future<void> get(String url,
      {Map<String, String>? headers,
      Map<String, String?>? params,
      Map<String, String>? qs}) async {
    var allHeaders = (headers ?? {})..addAll(_defaultHeaders);
    Uri uri = _buildUri(url: url, params: params, qs: qs);
    await client.get(uri, headers: allHeaders);
  }

  Uri _buildUri(
      {required String url,
      Map<String, String?>? params,
      Map<String, String>? qs}) {
    if (params != null) {
      params.forEach(
        (key, value) => url = url.replaceFirst(":$key", value ?? ""),
      );
    }
    if (qs != null) {
      url += "?${qs.entries.map((e) => "${e.key}=${e.value}").join("&")}";
    }

    if (url.endsWith("/")) url = url.substring(0, url.length - 1);
    return Uri.parse(url);
  }
}

class MockClient extends Mock implements Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late Client client;
  late HttpClient sut;
  late String url;

  setUp(() {
    client = MockClient();
    sut = HttpClient(client: client);
    url = Faker().internet.httpUrl();

    when(() => client.get(any(), headers: any(named: "headers")))
        .thenAnswer((_) async => Response("", 200));
  });

  setUpAll(() => {registerFallbackValue(FakeUri())});

  group("get", () {
    test("should request with correct method", () async {
      await sut.get("");
      verify(() => client.get(any(), headers: any(named: "headers"))).called(1);
    });

    test("should request with correct url", () async {
      await sut.get(url);
      verify(() => client.get(Uri.parse(url), headers: any(named: "headers")))
          .called(1);
    });

    test("should request with default headers", () async {
      await sut.get(url);
      verify(() => client.get(any(), headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          })).called(1);
    });

    test("should request with custom headers", () async {
      final customHeaders = {
        "Authorization": "Bearer token",
      };
      await sut.get(url, headers: customHeaders);
      verify(() => client.get(any(), headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer token",
          })).called(1);
    });

    test("should request with correct params", () async {
      url = "https://any-url.com/api/:id/:key2";

      await sut.get(url, params: {"id": "value", "key2": "value2"});

      verify(() => client.get(
            Uri.parse("https://any-url.com/api/value/value2"),
            headers: any(named: "headers"),
          )).called(1);
    });

    test("should request with optional params", () async {
      url = "https://any-url.com/api/:id/:key2";

      await sut.get(url, params: {"id": "value", "key2": null});

      verify(() => client.get(
            Uri.parse("https://any-url.com/api/value"),
            headers: any(named: "headers"),
          )).called(1);
    });

    test("should request with invalid params", () async {
      url = "https://any-url.com/api/:id/:key2";

      await sut.get(url, params: {"id": "value"});

      verify(() => client.get(
            Uri.parse("https://any-url.com/api/value/:key2"),
            headers: any(named: "headers"),
          )).called(1);
    });

    test("should request with correct queryStrings", () async {
      await sut.get(url, qs: {"id": "value", "key2": "value2"});

      verify(() => client.get(
            Uri.parse("$url?id=value&key2=value2"),
            headers: any(named: "headers"),
          )).called(1);
    });

    test("should request with correct queryStrings and params", () async {
      url = "https://any-url.com/api/:id";

      await sut.get(url, params: {"id": "value"}, qs: {"key2": "value2"});

      verify(() => client.get(
            Uri.parse("https://any-url.com/api/value?key2=value2"),
            headers: any(named: "headers"),
          )).called(1);
    });
  });
}
