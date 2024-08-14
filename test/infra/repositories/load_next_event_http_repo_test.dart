import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

class LoadNextEventHttpRepository {
  final Client httpClient;
  final String url;
  Map<String, String> headers = {
    "content-type": "application/json",
    "accept": "application/json",
  };

  LoadNextEventHttpRepository({required this.httpClient, required this.url});

  Future<void> loadNextEvent({required String groupId}) async {
    await httpClient.get(Uri.parse(url.replaceFirst(":groupId", groupId)),
        headers: headers);
  }
}

class MockClient extends Mock implements Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late String groupId;
  late Client client;
  late LoadNextEventHttpRepository sut;
  const url = "https://any-url.com/api/v1/groups/:groupId/next-event";

  setUp(() {
    groupId = Faker().guid.guid();
    client = MockClient();
    sut = LoadNextEventHttpRepository(httpClient: client, url: url);
    when(() => client.get(any(), headers: any(named: "headers")))
        .thenAnswer((_) async => Response("", 200));
  });

  setUpAll(() => {registerFallbackValue(FakeUri())});

  test("should request with correct method", () async {
    await sut.loadNextEvent(groupId: groupId);
    verify(() => client.get(any(), headers: any(named: "headers"))).called(1);
  });

  test("should request with correct url", () async {
    await sut.loadNextEvent(groupId: groupId);
    Uri expectedUri = Uri.parse(url.replaceFirst(":groupId", groupId));
    verify(() => client.get(expectedUri, headers: any(named: "headers")))
        .called(1);
  });

  test("should request with correct headers", () async {
    await sut.loadNextEvent(groupId: groupId);
    verify(() => client.get(any(), headers: sut.headers)).called(1);
  });
}
