import 'dart:convert';

import 'package:advanced_flutter/infra/cache/clients/cache_get_client.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CacheManagerAdapter implements CacheGetClient {
  final BaseCacheManager cacheManager;

  CacheManagerAdapter({required this.cacheManager});

  @override
  Future get(String key) async {
    try {
      final info = await cacheManager.getFileFromCache(key);
      if (info == null) return null;
      if (info.validTill.isBefore(DateTime.now()) || !info.file.existsSync()) {
        return null;
      }

      final response = await info.file.readAsString();
      return jsonDecode(response);
    } catch (e) {
      return null;
    }
  }
}