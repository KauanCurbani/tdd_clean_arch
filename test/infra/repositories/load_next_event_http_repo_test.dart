import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

class LoadNextEventHttpRepository {
  final Client httpClient;

  LoadNextEventHttpRepository({required this.httpClient});

  Future<void> loadNextEvent({required String groupId}) async {
    await httpClient.get(Uri.parse("https://any-url.com"));
  }
}

class MockClient extends Mock implements Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late String groupId;
  late Client client;

  setUp(() {
    groupId = Faker().guid.guid();
    client = MockClient();

    when(() => client.get(any())).thenAnswer((_) async => Response("", 200));
  });

  setUpAll(() => {registerFallbackValue(FakeUri())});

  test("should request with correct method", () async {
    final sut = LoadNextEventHttpRepository(httpClient: client);
    await sut.loadNextEvent(groupId: groupId);

    verify(() => client.get(any())).called(1);
  });
}
