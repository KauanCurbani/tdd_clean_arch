import 'package:advanced_flutter/domain/entities/next_event.dart';
import 'package:advanced_flutter/domain/repositories/load_next_event_repository.dart';
import 'package:advanced_flutter/infra/api/client/http_get_client.dart';
import 'package:advanced_flutter/infra/api/mappers/next_event_mapper.dart';

final class LoadNextEventApiRepository implements LoadNextEventRepository {
  final String url;
  final HttpGetClient httpClient;

  const LoadNextEventApiRepository({required this.httpClient, required this.url});

  @override
  Future<NextEvent> loadNextEvent({required String groupId}) async {
    final response = await httpClient.get(url, params: {"groupId": groupId});
    return NextEventMapper().fromJson(response);
  }
}
