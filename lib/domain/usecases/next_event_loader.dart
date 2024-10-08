import 'package:advanced_flutter/domain/entities/next_event.dart';
import 'package:advanced_flutter/domain/repositories/load_next_event_repository.dart';

class NextEventLoader {
  final LoadNextEventRepository repository;

  const NextEventLoader({required this.repository});

  Future<NextEvent> call({required String groupId}) async {
    return await repository.loadNextEvent(groupId: groupId);
  }
}
