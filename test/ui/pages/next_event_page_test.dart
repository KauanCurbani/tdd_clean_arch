import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart';

final class NextEventViewModel {
  final List<NextEventPlayerViewModel> goalkeepers;

  const NextEventViewModel({
    this.goalkeepers = const [],
  });
}

final class NextEventPlayerViewModel {
  final String name;

  const NextEventPlayerViewModel({
    required this.name,
  });
}

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
      body: StreamBuilder<NextEventViewModel>(
        stream: widget.presenter.nextEventStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return const Text("Erro ao carregar os dados");
          }

          final viewModel = snapshot.data!;

          return ListView(
            children: [
              if (viewModel.goalkeepers.isNotEmpty)
                ListSection(
                  title: "DENTRO - GOLEIROS",
                  items: viewModel.goalkeepers,
                ),
            ],
          );
        },
      ),
    );
  }
}

final class ListSection extends StatelessWidget {
  final String title;
  final List<NextEventPlayerViewModel> items;
  const ListSection({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title),
        Text(items.length.toString()),
        ...items.map((player) => Text(player.name)),
      ],
    );
  }
}

abstract class NextEventPresenter {
  void load(String groupId);
  Stream<NextEventViewModel> get nextEventStream;
}

final class NextEventPresenterMock with Mock implements NextEventPresenter {}

void main() {
  late NextEventPresenter presenterMock;
  late Widget sut;
  late String groupId;
  late BehaviorSubject<NextEventViewModel> nextEventSubject;

  void emitNextEventWith({List<NextEventPlayerViewModel> goalkeepers = const []}) {
    nextEventSubject.add(NextEventViewModel(goalkeepers: goalkeepers));
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
  });

  testWidgets("should not present all section if list is empty", (tester) async {
    await tester.pumpWidget(sut);
    emitNextEventWith();
    await tester.pump();
    expect(find.text("DENTRO - GOLEIROS"), findsNothing);
  });
}
