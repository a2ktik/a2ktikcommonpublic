import 'package:playlr_audio_player/cache.dart' as cache;

export 'package:playlr_audio_player/cache.dart' show globalCacheOrNull;
export 'package:tekartik_file_cache_flutter/file_cache_flutter.dart';

/// Default package name for cache
var packageName = 'a2ktik_kar';

/// Initialize the cache database
Future<cache.FileCacheDatabase> karInitCache() async {
  return await cache.initCacheDatabase(packageName: packageName);
}

/// Cache database
late cache.FileCacheDatabase karCacheDatabase;

/// Karaoke ready
var karReady = () async {
  karCacheDatabase = await karInitCache();
}();
