import 'package:advanced_flutter/presentation/presenters/next_event_presenter.dart';
import 'package:advanced_flutter/ui/components/player_position.dart';
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

    when(() => presenterMock.load(any())).thenAnswer((_) async {});
    when(() => presenterMock.nextEventStream).thenAnswer((_) => nextEventSubject.stream);
  });

  testWidgets("should load event data on page init", (WidgetTester tester) async {
    await tester.pumpWidget(sut);
    verify(() => presenterMock.load(groupId)).called(1);
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
        NextEventPlayerViewModel(name: "Rodrigo"),
        NextEventPlayerViewModel(name: "Rafael"),
        NextEventPlayerViewModel(name: "Kauan"),
      ],
    );
    await tester.pump();
    expect(find.text("DENTRO - GOLEIROS"), findsOneWidget);
    expect(find.text("3"), findsOneWidget);
    expect(find.text("Rodrigo"), findsOneWidget);
    expect(find.text("Rafael"), findsOneWidget);
    expect(find.text("Kauan"), findsOneWidget);
    expect(find.byType(PlayerPosition), findsExactly(3));
  });

  testWidgets("should present players section", (tester) async {
    await tester.pumpWidget(sut);
    emitNextEventWith(
      players: const [
        NextEventPlayerViewModel(name: "Rodrigo"),
        NextEventPlayerViewModel(name: "Rafael"),
        NextEventPlayerViewModel(name: "Kauan"),
      ],
    );
    await tester.pump();
    expect(find.text("DENTRO - JOGADORES"), findsOneWidget);
    expect(find.text("3"), findsOneWidget);
    expect(find.text("Rodrigo"), findsOneWidget);
    expect(find.text("Rafael"), findsOneWidget);
    expect(find.text("Kauan"), findsOneWidget);
    expect(find.byType(PlayerPosition), findsExactly(3));
  });

  testWidgets("should present out section", (tester) async {
    await tester.pumpWidget(sut);
    emitNextEventWith(
      out: const [
        NextEventPlayerViewModel(name: "Rodrigo"),
        NextEventPlayerViewModel(name: "Rafael"),
        NextEventPlayerViewModel(name: "Kauan"),
      ],
    );
    await tester.pump();
    expect(find.text("FORA"), findsOneWidget);
    expect(find.text("3"), findsOneWidget);
    expect(find.text("Rodrigo"), findsOneWidget);
    expect(find.text("Rafael"), findsOneWidget);
    expect(find.text("Kauan"), findsOneWidget);
    expect(find.byType(PlayerPosition), findsExactly(3));
  });

  testWidgets("should present doubt section", (tester) async {
    await tester.pumpWidget(sut);
    emitNextEventWith(
      doubt: const [
        NextEventPlayerViewModel(name: "Rodrigo"),
        NextEventPlayerViewModel(name: "Rafael"),
        NextEventPlayerViewModel(name: "Kauan"),
      ],
    );
    await tester.pump();
    expect(find.text("DÚVIDA"), findsOneWidget);
    expect(find.text("3"), findsOneWidget);
    expect(find.text("Rodrigo"), findsOneWidget);
    expect(find.text("Rafael"), findsOneWidget);
    expect(find.text("Kauan"), findsOneWidget);
    expect(find.byType(PlayerPosition), findsExactly(3));
  });

  testWidgets("should not present all section if list is empty", (tester) async {
    await tester.pumpWidget(sut);
    emitNextEventWith();
    await tester.pump();
    expect(find.text("DENTRO - GOLEIROS"), findsNothing);
    expect(find.text("DENTRO - JOGADORES"), findsNothing);
    expect(find.text("FORA"), findsNothing);
    expect(find.text("DÚVIDA"), findsNothing);
    expect(find.byType(PlayerPosition), findsNothing);
  });
}
