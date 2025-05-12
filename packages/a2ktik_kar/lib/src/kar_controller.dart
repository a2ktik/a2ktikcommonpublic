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
  }) => _KarController(
    audioSource: audioSource,
    lyricsSource: lyricsSource,
    appAudioPlayer: appAudioPlayer,
  );

  /// The audio source for the karaoke player
  KarAudioSource get audioSource;

  /// The lyrics source for the karaoke player
  KarLyricsSource get lyricsSource;

  /// Play
  Future<void> play({Duration? start, Duration? end});

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

  /// Creates a new karaoke controller
  _KarController({
    required this.audioSource,
    required this.lyricsSource,
    required this.appAudioPlayer,
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
      lyricsData: parseLyricLrc(lyrics),
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
  Future<void> play({Duration? start, Duration? end}) async {
    await ready;
    await songPlayer.playFromTo(from: start, to: end);
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

/// Extension for the karaoke controller (private
extension KarControllerPrvExt on KarController {
  _KarController get _self => this as _KarController;

  /// Lyrics data controller
  LyricsDataController get lyricsDataController => _self.lyricsDataController;

  /// Song audio player
  //SongAudioPlayer get songPlayer => _self.songPlayer;
  /// Ready
  Future<bool> get ready => _self.ready;
}
