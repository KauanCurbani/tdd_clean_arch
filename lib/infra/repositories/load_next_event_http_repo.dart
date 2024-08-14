import 'dart:convert';

import 'package:advanced_flutter/domain/entities/next_event.dart';
import 'package:advanced_flutter/domain/entities/next_event_player.dart';
import 'package:advanced_flutter/domain/repositories/load_next_event_repository.dart';
import 'package:http/http.dart';

class LoadNextEventHttpRepository implements LoadNextEventRepository {
  final Client httpClient;
  final String url;
  final Map<String, String> _headers = {
    "content-type": "application/json",
    "accept": "application/json",
  };

  LoadNextEventHttpRepository({required this.httpClient, required this.url});

  @override
  Future<NextEvent> loadNextEvent({required String groupId}) async {
    final response = await httpClient.get(
        Uri.parse(url.replaceFirst(":groupId", groupId)),
        headers: _headers);

    if (response.statusCode == 400) throw DomainError.unexpected;
    if (response.statusCode == 401) throw DomainError.sessionExpired;
    if (response.statusCode == 403) throw DomainError.unexpected;
    if (response.statusCode == 404) throw DomainError.unexpected;
    if (response.statusCode == 500) throw DomainError.unexpected;


    final event = jsonDecode(response.body);

    return NextEvent(
      groupName: event["groupName"],
      date: DateTime.parse(event["date"]),
      players: (event["players"] as List)
          .map((player) => NextEventPlayer(
                id: player["id"],
                name: player["name"],
                isConfirmed: player["isConfirmed"],
                confirmationDate:
                    DateTime.tryParse(player["confirmationDate"] ?? ""),
                photo: player["photo"],
                position: player["position"],
              ))
          .toList(),
    );
  }
}

enum DomainError { unexpected, sessionExpired }
