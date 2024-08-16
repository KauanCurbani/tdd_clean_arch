import 'package:advanced_flutter/domain/entities/errors.dart';
import 'package:advanced_flutter/domain/entities/next_event.dart';
import 'package:advanced_flutter/domain/repositories/load_next_event_repository.dart';
import 'package:advanced_flutter/infra/cache/clients/cache_get_client.dart';
import 'package:advanced_flutter/infra/cache/mappers/next_event_mapper.dart';

class LoadNextEventCacheRepository implements LoadNextEventRepository {
  CacheGetClient cacheGetClient;
  String key;

  LoadNextEventCacheRepository({required this.cacheGetClient, required this.key});

  @override
  Future<NextEvent> loadNextEvent({required String groupId}) async {
    final response = await cacheGetClient.get("$key:$groupId");
    if (response == null) {
      throw UnexpectedError();
    }
    return NextEventMapper().fromJson(response);
  }
}
