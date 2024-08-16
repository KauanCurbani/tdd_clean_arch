import 'package:advanced_flutter/domain/usecases/next_event_loader.dart';
import 'package:advanced_flutter/infra/api/adapters/http_adapter.dart';
import 'package:advanced_flutter/infra/api/repositories/load_next_event_api_repo.dart';
import 'package:advanced_flutter/presentation/rx/next_event_rx_presenter.dart';
import 'package:advanced_flutter/ui/pages/next_event_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

class HttpClientMock extends Mock implements Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late Client client;

  setUp(() {
    client = HttpClientMock();
  });

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  testWidgets("should present NextEventPage", (tester) async {
    when(() => client.get(any(), headers: any(named: "headers")))
        .thenAnswer((_) async => Response('''
       {
            "id": "1",
            "groupName": "Pelada Chega+",
            "date": "2024-01-01T00:00:00",
            "players":[
                {
                    "id": "1",
                    "name": "Jogador 1",
                    "position": "goalkeeper",
                    "confirmationDate": "2024-01-01T00:00:00",
                    "isConfirmed": true
                },
                {
                    "id": "2",
                    "name": "Jogador 2",
                    "position": "midfielder",
                    "confirmationDate": "2024-01-01T00:00:00",
                    "isConfirmed": true
                },
                {
                    "id": "3",
                    "name": "Jogador 3",
                    "position": "defender",
                    "confirmationDate": "2024-01-01T00:00:00",
                    "isConfirmed": true
                },
                {
                    "id": "4",
                    "name": "Jogador 4",
                    "position": "forward",
                    "confirmationDate": "2024-01-01T00:00:00",
                    "isConfirmed": true
                },
                {
                    "id": "5",
                    "name": "Jogador 5",
                    "position": null,
                    "confirmationDate": "2024-01-01T00:00:00",
                    "isConfirmed": true
                }
            ]
       }
''', 200));

    final httpClient = HttpAdapter(client: client);
    final repository = LoadNextEventApiRepository(httpClient: httpClient, url: "");
    final useCase = NextEventLoader(repository: repository);
    final presenter = NextEventRxPresenter(nextEventLoader: useCase.call);
    final sut = MaterialApp(home: NextEventPage(presenter: presenter, groupId: "groupId"));

    await tester.pumpWidget(sut);
    await tester.pump();

    expect(find.text("DENTRO - GOLEIROS"), findsOneWidget);
    expect(find.text("1"), findsOneWidget);
    expect(find.text("Jogador 1"), findsOneWidget);
    expect(find.text("DENTRO - JOGADORES"), findsOneWidget);
  });
}
