import 'package:advanced_flutter/presentation/presenters/next_event_presenter.dart';
import 'package:advanced_flutter/ui/components/player_photo.dart';
import 'package:advanced_flutter/ui/components/player_position.dart';
import 'package:advanced_flutter/ui/components/player_status.dart';
import 'package:advanced_flutter/ui/pages/next_event_page.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart';

final class NextEventPresenterMock with Mock implements NextEventPresenter {}

void main() {
  late NextEventPresenter presenterMock;
  late Widget sut;
  late String groupId;
  late BehaviorSubject<NextEventViewModel> nextEventSubject;
  late BehaviorSubject<bool> isLoadingSubject;

  void emitNextEventWith({
    List<NextEventPlayerViewModel> goalkeepers = const [],
    List<NextEventPlayerViewModel> players = const [],
    List<NextEventPlayerViewModel> out = const [],
    List<NextEventPlayerViewModel> doubt = const [],
  }) {
    nextEventSubject.add(NextEventViewModel(
      goalkeepers: goalkeepers,
      players: players,
      out: out,
      doubt: doubt,
    ));
  }

  void emitNextEventError() {
    nextEventSubject.addError(Exception());
  }

  Widget makeSut() {
    return MaterialApp(
      home: NextEventPage(
        presenter: presenterMock,
        groupId: groupId,
      ),
    );
  }

  setUp(() {
    presenterMock = NextEventPresenterMock();
    groupId = Faker().guid.guid();
    sut = makeSut();
    nextEventSubject = BehaviorSubject<NextEventViewModel>();
    isLoadingSubject = BehaviorSubject<bool>();

    when(() => presenterMock.load(groupId: any(named: "groupId"))).thenAnswer((_) async {});
    when(() => presenterMock.load(groupId: any(named: "groupId"), isReload: any(named: "isReload")))
        .thenAnswer((_) async {});
    when(() => presenterMock.nextEventStream).thenAnswer((_) => nextEventSubject.stream);
    when(() => presenterMock.isLoadingStream).thenAnswer((_) => isLoadingSubject.stream);
  });

  testWidgets("should load event data on page init", (WidgetTester tester) async {
    await tester.pumpWidget(sut);
    verify(() => presenterMock.load(groupId: groupId)).called(1);
  });
  testWidgets("should present spinner when data is loading", (WidgetTester tester) async {
    await tester.pumpWidget(sut);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
  testWidgets("should hide spinner on loading success", (WidgetTester tester) async {
    await tester.pumpWidget(sut);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    nextEventSubject.add(const NextEventViewModel());
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets("should hide spinner on loading error", (WidgetTester tester) async {
    await tester.pumpWidget(sut);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    nextEventSubject.addError(Exception());
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets("should present goalkeepers section", (tester) async {
    await tester.pumpWidget(sut);
    emitNextEventWith(
      goalkeepers: const [
        NextEventPlayerViewModel(name: "Rodrigo", initials: "R"),
        NextEventPlayerViewModel(name: "Rafael", initials: "R"),
        NextEventPlayerViewModel(name: "Kauan", initials: "R"),
      ],
    );
    await tester.pump();
    expect(find.text("DENTRO - GOLEIROS"), findsOneWidget);
    expect(find.text("3"), findsOneWidget);
    expect(find.text("Rodrigo"), findsOneWidget);
    expect(find.text("Rafael"), findsOneWidget);
    expect(find.text("Kauan"), findsOneWidget);
    expect(find.byType(PlayerPosition), findsExactly(3));
    expect(find.byType(PlayerPhoto), findsExactly(3));
    expect(find.byType(PlayerStatus), findsExactly(3));
  });

  testWidgets("should present players section", (tester) async {
    await tester.pumpWidget(sut);
    emitNextEventWith(
      players: const [
        NextEventPlayerViewModel(name: "Rodrigo", initials: "R"),
        NextEventPlayerViewModel(name: "Rafael", initials: "R"),
        NextEventPlayerViewModel(name: "Kauan", initials: "R"),
      ],
    );
    await tester.pump();
    expect(find.text("DENTRO - JOGADORES"), findsOneWidget);
    expect(find.text("3"), findsOneWidget);
    expect(find.text("Rodrigo"), findsOneWidget);
    expect(find.text("Rafael"), findsOneWidget);
    expect(find.text("Kauan"), findsOneWidget);
    expect(find.byType(PlayerPhoto), findsExactly(3));
    expect(find.byType(PlayerPosition), findsExactly(3));
    expect(find.byType(PlayerStatus), findsExactly(3));
  });

  testWidgets("should present out section", (tester) async {
    await tester.pumpWidget(sut);
    emitNextEventWith(
      out: const [
        NextEventPlayerViewModel(name: "Rodrigo", initials: "R"),
        NextEventPlayerViewModel(name: "Rafael", initials: "R"),
        NextEventPlayerViewModel(name: "Kauan", initials: "R"),
      ],
    );
    await tester.pump();
    expect(find.text("FORA"), findsOneWidget);
    expect(find.text("3"), findsOneWidget);
    expect(find.text("Rodrigo"), findsOneWidget);
    expect(find.text("Rafael"), findsOneWidget);
    expect(find.text("Kauan"), findsOneWidget);
    expect(find.byType(PlayerPhoto), findsExactly(3));
    expect(find.byType(PlayerPosition), findsExactly(3));
    expect(find.byType(PlayerStatus), findsExactly(3));
  });

  testWidgets("should present doubt section", (tester) async {
    await tester.pumpWidget(sut);
    emitNextEventWith(
      doubt: const [
        NextEventPlayerViewModel(name: "Rodrigo", initials: "R"),
        NextEventPlayerViewModel(name: "Rafael", initials: "R"),
        NextEventPlayerViewModel(name: "Kauan", initials: "R"),
      ],
    );
    await tester.pump();
    expect(find.text("DÚVIDA"), findsOneWidget);
    expect(find.text("3"), findsOneWidget);
    expect(find.text("Rodrigo"), findsOneWidget);
    expect(find.text("Rafael"), findsOneWidget);
    expect(find.text("Kauan"), findsOneWidget);
    expect(find.byType(PlayerPhoto), findsExactly(3));
    expect(find.byType(PlayerPosition), findsExactly(3));
    expect(find.byType(PlayerStatus), findsExactly(3));
  });

  testWidgets("should not present all section if list is empty", (tester) async {
    await tester.pumpWidget(sut);
    emitNextEventWith();
    await tester.pump();
    expect(find.text("DENTRO - GOLEIROS"), findsNothing);
    expect(find.text("DENTRO - JOGADORES"), findsNothing);
    expect(find.text("FORA"), findsNothing);
    expect(find.text("DÚVIDA"), findsNothing);
    expect(find.byType(PlayerPhoto), findsNothing);
    expect(find.byType(PlayerPosition), findsNothing);
    expect(find.byType(PlayerStatus), findsNothing);
  });

  testWidgets("should present error message on load error", (tester) async {
    await tester.pumpWidget(sut);
    emitNextEventError();
    await tester.pump();
    expect(find.text("DENTRO - GOLEIROS"), findsNothing);
    expect(find.text("DENTRO - JOGADORES"), findsNothing);
    expect(find.text("FORA"), findsNothing);
    expect(find.text("DÚVIDA"), findsNothing);
    expect(find.byType(PlayerPhoto), findsNothing);
    expect(find.byType(PlayerPosition), findsNothing);
    expect(find.byType(PlayerStatus), findsNothing);
    expect(find.text("Algo errado aconteceu! Tente novamente."), findsOneWidget);
    expect(find.text("Recarregar"), findsOneWidget);
  });

  testWidgets("should load event data on reload click", (WidgetTester tester) async {
    await tester.pumpWidget(sut);
    emitNextEventError();
    await tester.pump();
    await tester.tap(find.text("Recarregar"));
    verify(() => presenterMock.load(groupId: groupId, isReload: true)).called(1);
  });

  testWidgets("should handle spinner on page busy event", (WidgetTester tester) async {
    await tester.pumpWidget(sut);
    nextEventSubject.addError(Exception());
    await tester.pump();
    isLoadingSubject.add(true);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    isLoadingSubject.add(false);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets("should load event data on pull to refresh", (WidgetTester tester) async {
    await tester.pumpWidget(sut);
    emitNextEventWith(goalkeepers: const [NextEventPlayerViewModel(name: "Rodrigo", initials: "R")]);
    await tester.pump();
    await tester.flingFrom(const Offset(50, 100), const Offset(0, 400), 800);
    await tester.pumpAndSettle();
    verify(() => presenterMock.load(groupId: groupId, isReload: true)).called(1);
  });
}
