import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class LoadNextEventApiRepository {
  final String url;
  final HttpGetClient httpClient;

  LoadNextEventApiRepository({required this.httpClient, required this.url});

  Future<void> loadNextEvent({required String groupId}) async {
    await httpClient.get(url: url);
  }
}

abstract class HttpGetClient {
  Future<void> get({required String url});
}

class HttpGetClientMock with Mock implements HttpGetClient {}

void main() {
  late String groupId;
  late String url;
  late HttpGetClient httpClient;
  late LoadNextEventApiRepository sut;

  setUp(() {
    groupId = Faker().guid.guid();
    url = "https://any-url.com/api/v1/groups/:groupId/next-event";
    httpClient = HttpGetClientMock();
    sut = LoadNextEventApiRepository(httpClient: httpClient, url: url);

    when(() => httpClient.get(url: any(named: "url"))).thenAnswer((_) async {});
  });

  test("should call httpClient with correct url", () async {
    await sut.loadNextEvent(groupId: groupId);
    verify(() => httpClient.get(url: url.replaceFirst(":groupId", groupId)))
        .called(1);
  });
}
