import 'package:advanced_flutter/domain/entities/errors.dart';
import 'package:advanced_flutter/domain/entities/next_event.dart';
import 'package:advanced_flutter/domain/entities/next_event_player.dart';
import 'package:advanced_flutter/infra/cache/clients/cache_get_client.dart';
import 'package:advanced_flutter/infra/cache/repositories/load_next_event_cache_repo.dart';
import 'package:advanced_flutter/infra/types/json.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class CacheGetClientMock with Mock implements CacheGetClient {}

void main() {
  late String groupId;
  late LoadNextEventCacheRepository sut;
  late CacheGetClientMock cacheGetClient;
  late String key;

  Json jsonResponse = {
    "groupName": "Group Name",
    "date": DateTime.now(),
    "players": [
      {
        "id": "1",
        "name": "Player 1",
        "isConfirmed": true,
        "confirmationDate": DateTime.now(),
        "photo": "photo",
        "position": "position"
      },
      {
        "id": "2",
        "name": "Player 2",
        "isConfirmed": false,
      },
    ]
  };

  setUp(() {
    groupId = Faker().guid.guid();
    cacheGetClient = CacheGetClientMock();
    key = "next-event";
    sut = LoadNextEventCacheRepository(cacheGetClient: cacheGetClient, key: key);

    when(() => cacheGetClient.get(any())).thenAnswer((_) async {
      return jsonResponse;
    });
  });
  test("should call CacheClient with correct url", () async {
    await sut.loadNextEvent(groupId: groupId);
    verify(() => cacheGetClient.get("$key:$groupId")).called(1);
  });

  test("should return NextEvent data", () async {
    final event = await sut.loadNextEvent(groupId: groupId);

    expect(event, isA<NextEvent>());
    expect(event.date, isA<DateTime>());
    expect(event.groupName, isA<String>());
    expect(event.players, isA<List<NextEventPlayer>>());
    expect(event.groupName, jsonResponse["groupName"]);

    final player = event.players[0];
    expect(player.id, jsonResponse["players"][0]["id"]);
    expect(player.name, jsonResponse["players"][0]["name"]);
    expect(player.isConfirmed, jsonResponse["players"][0]["isConfirmed"]);
    expect(player.confirmationDate, jsonResponse["players"][0]["confirmationDate"]);
    expect(player.photo, jsonResponse["players"][0]["photo"]);
    expect(player.position, jsonResponse["players"][0]["position"]);
  });

  test("should rethrow on error", () async {
    when(() => cacheGetClient.get(any())).thenThrow(Exception());
    final future = sut.loadNextEvent(groupId: groupId);
    expect(future, throwsA(isA<Exception>()));
  });

  test("should throw UnexpectedError on null response", () async {
    when(() => cacheGetClient.get(any())).thenAnswer((_) async => null);
    final future = sut.loadNextEvent(groupId: groupId);
    expect(future, throwsA(isA<UnexpectedError>()));
  });
}
