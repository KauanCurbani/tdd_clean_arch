import 'package:advanced_flutter/domain/entities/errors.dart';
import 'package:advanced_flutter/infra/api/adapters/http_adapter.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

class MockClient extends Mock implements Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late Client client;
  late HttpAdapter sut;
  late String url;

  setUp(() {
    client = MockClient();
    sut = HttpAdapter(client: client);
    url = Faker().internet.httpUrl();

    when(() => client.get(any(), headers: any(named: "headers")))
        .thenAnswer((_) async => Response('{"test": "test"}', 200));
  });

  setUpAll(() => {registerFallbackValue(FakeUri())});

  group("get", () {
    test("should request with correct method", () async {
      await sut.get("");
      verify(() => client.get(any(), headers: any(named: "headers"))).called(1);
    });

    test("should request with correct url", () async {
      await sut.get(url);
      verify(() => client.get(Uri.parse(url), headers: any(named: "headers"))).called(1);
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

    test("should UnexpectedError on 400 error", () async {
      when(() => client.get(any(), headers: any(named: "headers")))
          .thenAnswer((_) async => Response("Bad Request", 400));
      final future = sut.get(url);
      expect(future, throwsA(const TypeMatcher<UnexpectedError>()));
    });

    test("should SessionExpired on 401 error", () async {
      when(() => client.get(any(), headers: any(named: "headers")))
          .thenAnswer((_) async => Response("Unauthorized", 401));
      final future = sut.get(url);
      expect(future, throwsA(const TypeMatcher<SessionExpiredError>()));
    });

    test("should UnexpectedError on 403 error", () async {
      when(() => client.get(any(), headers: any(named: "headers")))
          .thenAnswer((_) async => Response("Forbidden", 403));
      final future = sut.get(url);
      expect(future, throwsA(const TypeMatcher<UnexpectedError>()));
    });

    test("should UnexpectedError on 404 error", () async {
      when(() => client.get(any(), headers: any(named: "headers")))
          .thenAnswer((_) async => Response("Not Found", 404));
      final future = sut.get(url);
      expect(future, throwsA(const TypeMatcher<UnexpectedError>()));
    });

    test("should UnexpectedError on 500 error", () async {
      when(() => client.get(any(), headers: any(named: "headers")))
          .thenAnswer((_) async => Response("Internal Server Error", 500));
      final future = sut.get(url);
      expect(future, throwsA(const TypeMatcher<UnexpectedError>()));
    });

    test("should return a Map", () async {
      when(() => client.get(any(), headers: any(named: "headers")))
          .thenAnswer((_) async => Response('{"key": "value"}', 200));

      final response = await sut.get(url);

      expect(response, isA<Map>());
      expect(response["key"], "value");
    });

    test("should return a List<Map>", () async {
      when(() => client.get(any(), headers: any(named: "headers")))
          .thenAnswer((_) async => Response('[{"key": "value"}, {"key2": "value2"}]', 200));

      final response = await sut.get(url);

      expect(response, isA<List>());
      expect(response.first, isA<Map>());
      expect(response.first["key"], "value");

      expect(response.last, isA<Map>());
      expect(response.last["key2"], "value2");
    });

    test("should return a Map with List inside", () async {
      when(() => client.get(any(), headers: any(named: "headers")))
          .thenAnswer((_) async => Response('{"key": ["value", "value2"]}', 200));

      final response = await sut.get(url);

      expect(response, isA<Map>());
      expect(response["key"], isA<List>());
      expect(response["key"].first, "value");
      expect(response["key"].last, "value2");
    });

    test("should throw Unexpected error if response is empty", () async {
      when(() => client.get(any(), headers: any(named: "headers")))
          .thenAnswer((_) async => Response("", 200));

      final future = sut.get(url);
      expect(future, throwsA(const TypeMatcher<UnexpectedError>()));
    });

    test("should convert headers value to String", () async {
      when(() => client.get(any(), headers: any(named: "headers")))
          .thenAnswer((_) async => Response('{"key1": "value"}', 200));

      await sut.get(url, headers: {"key": 1, "bool": true, "null": null});

      verify(() => client.get(any(), headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "key": "1",
            "bool": "true",
            "null": "null",
          })).called(1);
    });

    test("should convert params to String", () async {
      url = "https://any-url.com/api/:id/:key2/:null";

      await sut.get(url, params: {"id": 1, "key2": true, "null": null});

      verify(() => client.get(
            Uri.parse("https://any-url.com/api/1/true"),
            headers: any(named: "headers"),
          )).called(1);
    });

    test("should convert queryString values to String", () async {
      await sut.get(url, qs: {"key": 1, "bool": true, "null": null});

      verify(() => client.get(
            Uri.parse("$url?key=1&bool=true&null=null"),
            headers: any(named: "headers"),
          )).called(1);
    });
  });
}
