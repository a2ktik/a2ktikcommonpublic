import 'package:a2ktik_kar/kar.dart';
import 'package:festenao_common_flutter/common_utils.dart';
import 'package:festenao_lyrics_player/lyrics_player.dart';
import 'package:playlr_audio_player/player.dart';
import 'kar_cache.dart';

/// A controller for the karaoke player
abstract class KarController {
  /// Creates a new karaoke controller
  factory KarController({
    required AppAudioPlayer appAudioPlayer,
    required KarAudioSource audioSource,
    required KarLyricsSource lyricsSource,
    Duration? start,
    Duration? end,
  }) => _KarController(
    audioSource: audioSource,
    lyricsSource: lyricsSource,
    appAudioPlayer: appAudioPlayer,
    start: start,
    end: end,
  );

  /// The audio source for the karaoke player
  KarAudioSource get audioSource;

  /// The lyrics source for the karaoke player
  KarLyricsSource get lyricsSource;

  /// Play
  Future<void> play({Duration? start, Duration? end, double? playbackRate});

  /// Pause
  Future<void> pause();

  /// Resume
  Future<void> resume();

  /// Dispose the controller
  void dispose();
}

/// A controller for the karaoke player
class _KarController implements KarController {
  LyricsDataController get lyricsDataController => lyricsDataControllerOrNull!;
  LyricsDataController? lyricsDataControllerOrNull;
  final AppAudioPlayer appAudioPlayer;

  SongAudioPlayer get songPlayer => songPlayerOrNull!;
  SongAudioPlayer? songPlayerOrNull;
  final Duration? start;
  final Duration? end;

  /// Creates a new karaoke controller
  _KarController({
    required this.audioSource,
    required this.lyricsSource,
    required this.appAudioPlayer,
    required this.start,
    required this.end,
  });

  var disposed = false;
  late SongAudioPlayer player;

  /// The audio source for the karaoke player
  @override
  final KarAudioSource audioSource;

  /// The lyrics source for the karaoke player
  @override
  final KarLyricsSource lyricsSource;

  final _lock = Lock();
  late final ready = () async {
    await karReady;
    if (disposed) {
      return false;
    }
    var lyrics = await lyricsSource.getString();
    if (disposed) {
      return false;
    }
    lyricsDataControllerOrNull = LyricsDataController(
      lyricsData: parseLyricLrc(lyrics).extractFromTo(from: start, to: end),
    );
    if (audioSource is! KarAudioSourceAsset) {
      throw Exception('Audio source is not a KarAudioSource');
    }
    var asset = (audioSource as KarAudioSourceAsset).asset;
    var playerSource = karCacheDatabase.assetToSource(asset);

    var song = AppAudioPlayerSong(playerSource);
    await _lock.synchronized(() async {
      if (disposed) {
        return;
      }
      songPlayerOrNull = await appAudioPlayer.loadSong(song);
    });

    () async {
      await for (var state in songPlayer.positionStream) {
        lyricsDataControllerOrNull?.update((state ?? Duration.zero));
      }
    }().unawait();
    return true;
  }();

  /// The audio player for the karaoke player
  @override
  Future<void> play({
    Duration? start,
    Duration? end,
    double? playbackRate,
  }) async {
    await ready;
    await songPlayer.playFromTo(
      from: start ?? this.start,
      to: end ?? this.end,
      playbackRate: playbackRate,
    );
  }

  @override
  void dispose() {
    disposed = true;
    _lock.synchronized(() async {
      songPlayerOrNull?.dispose();
    });
  }

  @override
  Future<void> pause() async {
    await songPlayerOrNull?.pause();
  }

  @override
  Future<void> resume() async {
    await songPlayerOrNull?.resume();
  }
}

/// Extension for the karaoke controller (private)
extension KarControllerPrvExt on KarController {
  _KarController get _self => this as _KarController;

  /// Lyrics data controller
  LyricsDataController get lyricsDataController => _self.lyricsDataController;
}

/// Extension for the karaoke controller (public)
extension KarControllerExt on KarController {
  /// Ready
  Future<bool> get ready => _self.ready;

  /// position stream
  Stream<Duration?> get positionStream => _self.songPlayer.positionStream;

  /// True if playing
  bool get isPlaying => _self.songPlayer.isPlayingSync();

  /// Get current position
  Future<Duration?> getCurrentPosition() {
    return _self.songPlayer.getCurrentPosition();
  }
}
