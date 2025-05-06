import 'package:festenao_common_flutter/common_utils_flutter.dart';

/// A source of lyrics for a karaoke player
abstract class KarLyricsSource {
  /// Asset based lyrics source
  factory KarLyricsSource.asset(String asset) {
    return _KarLyricsSourceAsset(asset: asset);
  }

  /// Get the lyrics as a string
  Future<String> getString();
}

class _KarLyricsSourceAsset implements KarLyricsSource {
  final String asset;

  _KarLyricsSourceAsset({required this.asset});

  @override
  Future<String> getString() async {
    return tkRootBundle.loadString(asset);
  }
}
