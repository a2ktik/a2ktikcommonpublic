/// A source of audio for a karaoke player
class KarAudioSource {}

/// Asset based audio source
class KarAudioSourceAsset implements KarAudioSource {
  /// Asset based audio source
  final String asset;

  /// Asset based audio source
  KarAudioSourceAsset({required this.asset});
}
