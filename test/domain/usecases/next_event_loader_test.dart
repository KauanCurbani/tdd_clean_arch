import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';

class NextEventLoader {
  final LoadNextEventRepository repository;

  NextEventLoader({required this.repository});

  Future<void> call({required String groupId}) async {
    await repository.loadNextEvent(groupId: groupId);
  }
}

class LoadNextEventRepository {
  String? groupId;
  var callsCount = 0;

  Future<void> loadNextEvent({required String groupId}) async {
    this.groupId = groupId;
    callsCount++;
  }
}

void main() {
  test("should load event data from a repository", () async {
    final groupId = Faker().guid.guid();
    final repo = LoadNextEventRepository();
    final sut = NextEventLoader(repository: repo);
    await sut(groupId: groupId);
    expect(repo.groupId, groupId);
    expect(repo.callsCount, 1);
  });
}
