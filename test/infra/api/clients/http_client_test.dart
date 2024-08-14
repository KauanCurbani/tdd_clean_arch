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

  Future<void> get(String url, {Map<String, String>? headers}) async {
    var allHeaders = (headers ?? {})..addAll(_defaultHeaders);
    await client.get(Uri.parse(url), headers: allHeaders);
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
  });
}
