import 'package:advanced_flutter/domain/entities/next_event.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart';

final class NextEventPage extends StatefulWidget {
  final NextEventPresenter presenter;
  final String groupId;
  const NextEventPage({super.key, required this.presenter, required this.groupId});

  @override
  State<NextEventPage> createState() => _NextEventPageState();
}

class _NextEventPageState extends State<NextEventPage> {
  @override
  void initState() {
    super.initState();
    widget.presenter.load(widget.groupId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: widget.presenter.nextEventStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            return const CircularProgressIndicator();
          }
          return Container();
        },
      ),
    );
  }
}

abstract class NextEventPresenter {
  void load(String groupId);
  Stream get nextEventStream;
}

final class NextEventPresenterMock with Mock implements NextEventPresenter {}

void main() {
  late NextEventPresenter presenterMock;
  late Widget sut;
  late String groupId;
  late BehaviorSubject nextEventSubject;

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
    nextEventSubject = BehaviorSubject();

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
    nextEventSubject.add(NextEvent(groupName: "Group Name", date: DateTime.now(), players: []));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  
}
