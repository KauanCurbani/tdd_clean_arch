import 'package:advanced_flutter/domain/entities/next_event.dart';
import 'package:advanced_flutter/domain/repositories/load_next_event_repository.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class LoadNextEventFromApiWithCacheFallbackRepository implements LoadNextEventRepository {
  final LoadNextEventRepository api;
  final LoadNextEventRepository cache;

  const LoadNextEventFromApiWithCacheFallbackRepository({
    required this.api,
    required this.cache,
  });

  @override
  Future<NextEvent> loadNextEvent({required String groupId}) {
    final response = api.loadNextEvent(groupId: groupId);
    return response;
  }
}

class LoadNextEventApiMock with Mock implements LoadNextEventRepository {}

class LoadNextEventCacheMock with Mock implements LoadNextEventRepository {}

void main() {
  late String groupId;
  late LoadNextEventApiMock api;
  late LoadNextEventCacheMock cache;
  late LoadNextEventFromApiWithCacheFallbackRepository sut;
  NextEvent nextEvent = NextEvent(
    date: DateTime.now(),
    groupName: Faker().lorem.word(),
    players: [],
  );

  setUp(() {
    groupId = Faker().guid.guid();
    api = LoadNextEventApiMock();
    cache = LoadNextEventCacheMock();
    sut = LoadNextEventFromApiWithCacheFallbackRepository(
      api: api,
      cache: cache,
    );
    when(() => sut.loadNextEvent(groupId: any(named: "groupId")))
        .thenAnswer((_) async => nextEvent);
  });

  test("should load event data from API repo", () async {
    final response = await sut.loadNextEvent(groupId: groupId);
    expect(response, nextEvent);
    verify(() => sut.loadNextEvent(groupId: groupId)).called(1);
  });

  test("should save event data from api on cache", () async {
    await sut.loadNextEvent(groupId: groupId);
    verify(() => cache.loadNextEvent(groupId: groupId)).called(1);
  });
}
