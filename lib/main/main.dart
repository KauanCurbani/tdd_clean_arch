import 'package:advanced_flutter/domain/repositories/load_next_event_repository.dart';
import 'package:advanced_flutter/domain/usecases/next_event_loader.dart';
import 'package:advanced_flutter/infra/api/adapters/http_adapter.dart';
import 'package:advanced_flutter/infra/api/repositories/load_next_event_api_repo.dart';
import 'package:advanced_flutter/presentation/rx/next_event_rx_presenter.dart';
import 'package:advanced_flutter/ui/pages/next_event_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData(
        dividerTheme: const DividerThemeData(space: 0),
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.primaryContainer,
        ),
        brightness: Brightness.dark,
        colorScheme: colorScheme,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      home: makeNextEventPage(),
    );
  }
}

Widget makeNextEventPage() {
  final presenter = NextEventRxPresenter(nextEventLoader: makeNextEventLoader().call);
  return NextEventPage(presenter: presenter, groupId: "valid_id");
}

NextEventLoader makeNextEventLoader() {
  return NextEventLoader(repository: makeLoadNextEventApiRepo());
}

LoadNextEventRepository makeLoadNextEventApiRepo() {
  return LoadNextEventApiRepository(
      httpClient: makeHttpClient(), url: "http://10.0.2.2:8080/api/groups/:groupId/next_event");
}

HttpAdapter makeHttpClient() {
  return HttpAdapter(client: Client());
}
