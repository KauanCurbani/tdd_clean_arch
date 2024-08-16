@Timeout(Duration(seconds: 1))

import 'package:advanced_flutter/domain/entities/errors.dart';
import 'package:advanced_flutter/domain/entities/next_event.dart';
import 'package:advanced_flutter/domain/usecases/next_event_loader.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart';

final class NextEventRxPresenter {
  final Future<void> Function({required String groupId}) nextEventLoader;
  final nextEventSubject = BehaviorSubject();
  final isLoadingSubject = BehaviorSubject<bool>();

  NextEventRxPresenter({required this.nextEventLoader});

  Stream get nextEventStream => nextEventSubject.stream;
  Stream get isLoadingStream => isLoadingSubject.stream;

  Future<void> loadNextEvent({required String groupId, bool isReload = false}) async {
    try {
      if (isReload) isLoadingSubject.add(true);
      await nextEventLoader(groupId: groupId);
    } catch (e) {
      nextEventSubject.addError(e);
    } finally {
      if (isReload) isLoadingSubject.add(false);
    }
  }
}

class NextEventLoaderMock with Mock implements NextEventLoader {}

void main() {
  late NextEventLoaderMock loaderMock;
  late NextEventRxPresenter sut;
  late String groupId;

  setUp(() {
    loaderMock = NextEventLoaderMock();
    groupId = Faker().guid.guid();
    sut = NextEventRxPresenter(nextEventLoader: loaderMock.call);
    when(() => loaderMock.call(groupId: any(named: "groupId")))
        .thenAnswer((_) async => NextEvent(date: DateTime.now(), players: [], groupName: "groupName"));
  });

  test("should get event data", () async {
    await sut.loadNextEvent(groupId: groupId);
    verify(() => loaderMock.call(groupId: groupId)).called(1);
  });

  test("should emit correct events on reload with error", () async {
    when(() => loaderMock.call(groupId: groupId)).thenThrow(UnexpectedError());
    expectLater(sut.nextEventStream, emitsError(isA<UnexpectedError>()));
    await sut.loadNextEvent(groupId: groupId, isReload: true);
  });

  test("should emit correct events on isLoading with reload on error", () async {
    when(() => loaderMock.call(groupId: groupId)).thenThrow(UnexpectedError());
    expectLater(sut.isLoadingStream, emitsInOrder([true, false]));
    await sut.loadNextEvent(groupId: groupId, isReload: true);
  });

  test("should emit correct events on isLoading on error", () async {
    when(() => loaderMock.call(groupId: groupId)).thenThrow(UnexpectedError());
    await sut.loadNextEvent(groupId: groupId);
    sut.isLoadingStream.listen(neverCalled);
  });

  test("should emit correct events on isLoading with reload on success", () async {
    expectLater(sut.isLoadingStream, emitsInOrder([true, false]));
    await sut.loadNextEvent(groupId: groupId, isReload: true);
  });

  test("should emit correct events on isLoading on success", () async {
    await sut.loadNextEvent(groupId: groupId);
    sut.isLoadingStream.listen(neverCalled);
  });
}
