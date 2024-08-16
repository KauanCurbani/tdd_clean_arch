import 'package:advanced_flutter/ui/components/player_photo.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';



void main() {
  testWidgets("should render initials if photo is null", (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PlayerPhoto(initials: "AN", photo: null)));
    expect(find.text("AN"), findsOneWidget);
  });

  testWidgets("should hide initials when there is photo", (tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        MaterialApp(home: PlayerPhoto(initials: "AN", photo: Faker().internet.httpsUrl())),
      );
    });
    expect(find.text("AN"), findsNothing);
  });
}
