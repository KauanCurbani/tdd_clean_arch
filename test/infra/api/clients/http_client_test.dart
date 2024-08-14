import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

class HttpClient {
  final Client client;

  HttpClient({required this.client});

  Future<void> get(String url) async {
    await client.get(Uri.parse(url));
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

    when(() => client.get(any())).thenAnswer((_) async => Response("", 200));
  });

  setUpAll(() => {registerFallbackValue(FakeUri())});

  group("get", () {
    test("should request with correct method", () async {
      await sut.get("");
      verify(() => client.get(any())).called(1);
    });

    test("should request with correct url", () async {
      await sut.get(url);
      verify(() => client.get(Uri.parse(url))).called(1);
    });
  });
}
