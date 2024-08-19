import 'dart:convert';

import 'package:advanced_flutter/domain/entities/errors.dart';
import 'package:advanced_flutter/infra/cache/adapters/cache_manager_adapter.dart';
import 'package:faker/faker.dart';
import 'package:flutter_cache_manager/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';



class CacheManagerMock with Mock implements BaseCacheManager {}

class FileMock with Mock implements File {}

void main() {
  late String key;
  late CacheManagerAdapter sut;
  late CacheManagerMock cacheManager;
  late FileMock file;
  final DateTime validTill = DateTime.now().add(const Duration(days: 1));
  final DateTime oldDate = DateTime.now().subtract(const Duration(days: 1));

  setUp(() {
    key = Faker().randomGenerator.string(20);
    cacheManager = CacheManagerMock();
    sut = CacheManagerAdapter(cacheManager: cacheManager);
    file = FileMock();

    when(() => cacheManager.getFileFromCache(any())).thenAnswer((_) async {
      return null;
    });
  });

  test("should call getFileFromCache with correct input", () async {
    await sut.get(key);
    verify(() => cacheManager.getFileFromCache(key)).called(1);
  });

  test("should return null if cacheManager returns null", () async {
    when(() => cacheManager.getFileFromCache(any())).thenThrow(CacheException());
    final response = await sut.get(key);
    expect(response, isNull);
  });

  test("should return null if cache is old", () async {
    when(() => cacheManager.getFileFromCache(key)).thenAnswer(
      (_) async => FileInfo(file, FileSource.Cache, oldDate, ""),
    );
    when(() => file.existsSync()).thenReturn(true);
    when(() => file.readAsString()).thenAnswer((_) async => "{ \"key\": \"value\" }");

    final response = await sut.get(key);
    expect(response, isNull);
  });

  test("should return file if cache is valid", () async {
    when(() => cacheManager.getFileFromCache(key)).thenAnswer(
      (_) async => FileInfo(file, FileSource.Cache, validTill, ""),
    );

    when(() => file.existsSync()).thenReturn(true);
    when(() => file.readAsString()).thenAnswer((_) async => "{ \"key\": \"value\" }");

    final response = await sut.get(key);
    expect(response, isNotNull);
  });

  test("should return null if file does not exist", () async {
    when(() => cacheManager.getFileFromCache(key)).thenAnswer(
      (_) async => FileInfo(file, FileSource.Cache, validTill, ""),
    );

    when(() => file.existsSync()).thenReturn(false);

    final response = await sut.get(key);
    expect(response, isNull);
  });

  test("should return if file exists and cache is valid", () async {
    when(() => cacheManager.getFileFromCache(key)).thenAnswer(
      (_) async => FileInfo(file, FileSource.Cache, validTill, ""),
    );

    when(() => file.existsSync()).thenReturn(true);
    when(() => file.readAsString()).thenAnswer((_) async => "{ \"key\": \"value\" }");

    final response = await sut.get(key);
    expect(response, isNotNull);
  });

  test("should return infos as json", () async {
    final json = {"key": "value"};
    when(() => cacheManager.getFileFromCache(key)).thenAnswer(
      (_) async => FileInfo(file, FileSource.Cache, validTill, ""),
    );

    when(() => file.existsSync()).thenReturn(true);
    when(() => file.readAsString()).thenAnswer((_) async => jsonEncode(json));

    final response = await sut.get(key);
    expect(response, json);
  });

  test("should return null if cache is invalid json", () async {
    when(() => cacheManager.getFileFromCache(key)).thenAnswer(
      (_) async => FileInfo(file, FileSource.Cache, validTill, ""),
    );

    when(() => file.existsSync()).thenReturn(true);
    when(() => file.readAsString()).thenAnswer((_) async => "{ key: value }");

    final response = await sut.get(key);
    expect(response, isNull);
  });

  test("should return json if response is valid", () async {
    final json = {"key": "value"};
    when(() => cacheManager.getFileFromCache(key)).thenAnswer(
      (_) async => FileInfo(file, FileSource.Cache, validTill, ""),
    );

    when(() => file.existsSync()).thenReturn(true);
    when(() => file.readAsString()).thenAnswer((_) async => jsonEncode(json));

    final response = await sut.get(key);
    expect(response, json);
    expect(response, isA<Map>());
    expect(response["key"], "value");
  });
}
