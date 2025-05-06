import 'package:a2ktik_kar/kar.dart';
import 'package:festenao_audio_player/player.dart';
import 'package:festenao_common_flutter/common_utils_widget.dart';
import 'package:flutter/material.dart';

import 'package:tekaly_playlr_audio_assets/audio/assets.dart';

const assetAudioExample1 = audioAssetExample1;
const assetLyricsExample1 = 'assets/data/demo.lrc';

class AudioKaraokeParams {
  final String title;
  final String audioId;
  final String lrcId;
  final Duration? start;
  final Duration? end;

  const AudioKaraokeParams({
    required this.title,
    required this.audioId,
    required this.lrcId,
    this.start,
    this.end,
  });
}
// 16/9 = 1920/1080

class AudioKaraokePlayer extends StatefulWidget {
  final AudioKaraokeParams params;

  const AudioKaraokePlayer({super.key, required this.params});
  @override
  State<AudioKaraokePlayer> createState() => _AudioKaraokePlayerState();
}

class _AudioKaraokePlayerState
    extends AutoDisposeBaseState<AudioKaraokePlayer> {
  var appAudioPlayer = appAudioPlayerBlueFire;
  late KarController karController;
  AudioKaraokeParams get params => widget.params;
  late final ready = () async {
    try {
      var source = KarLyricsSource.asset(params.lrcId);
      var audioSource = KarAudioSourceAsset(asset: params.audioId);
      karController = KarController(
        appAudioPlayer: appAudioPlayerBlueFire,
        audioSource: audioSource,
        lyricsSource: source,
      );
    } catch (e, st) {
      // ignore: avoid_print
      print('Error: $e');
      // ignore: avoid_print
      print('StackTrace: $st');
    }
  }();
  @override
  void initState() {
    () async {
      await ready;
      await karController.play(start: params.start, end: params.end);
    }();

    super.initState();
  }

  String get videoId => widget.params.audioId;

  @override
  void dispose() {
    karController.dispose();
    // Remove the listener when the widget is disposed to avoid memory leaks
    //_controller?.removeListener(_positionListener);
    // Call the superclass method to ensure proper disposal
    super.dispose();
  }

  // Listener method that prints the current video playback position to the console
  // ignore: unused_element
  void _positionListener() {
    //print("position: ${_controller!.position}");
  }

  // Build method to create the widget's UI
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ready,
      builder: (context, asyncSnapshot) {
        var ready = asyncSnapshot.connectionState == ConnectionState.done;
        return Scaffold(
          // Create a Scaffold to provide a basic material design layout
          appBar: AppBar(
            // Set the title of the app
            title: Text(widget.params.title),
          ),
          body:
              ready
                  ? ListView(
                    // Create a ListView for scrolling through multiple widgets
                    padding: const EdgeInsets.all(8),
                    children: <Widget>[
                      BodyContainer(
                        child: TilePadding(
                          child: SizedBox(
                            //height: 150,
                            child: AspectRatio(
                              aspectRatio: 16 / 2.5,
                              child: KarLyricsView(
                                controller: karController,
                                style: LyricsDataPlayerStyle.defaultDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Play button to start video playback
                      BodyContainer(
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  muiSnack(context, 'paused');
                                  karController.pause();
                                },
                                icon: const Icon(Icons.pause_circle, size: 50),
                              ),
                              IconButton(
                                onPressed: () {
                                  muiSnack(context, 'playing');
                                  karController.resume();
                                  // Call the play method on the controller to start playback
                                  //_controller?.play.call();
                                },
                                icon: const Icon(Icons.play_circle, size: 50),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Builder(
                        builder: (_) {
                          if (!ready) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return AppAudioPlayerWidget(
                            player: appAudioPlayer,
                            song: null,
                          );
                        },
                      ),
                      // Pause button to stop video playback
                      /*
              Row(
                // Align buttons to the center of the row
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Button to seek back 5 seconds in the video
                  TextButton(
                    onPressed: () {
                      _controller!.seekTo(
                        _controller!.position - Duration(seconds: 5),
                      );
                    },
                    child: Icon(Icons.skip_previous, size: 50),
                  ),
                  // Button to seek forward 5 seconds in the video
                  TextButton(
                    onPressed: () {
                      _controller!.seekTo(
                        _controller!.position + Duration(seconds: 5),
                      );
                    },
                    child: Icon(Icons.skip_next, size: 50),
                  ),
                ],
              ),
              // Button to set playback speed to normal (1x)
              TextButton(
                onPressed: () {
                  _controller?.setPlaybackSpeed(1);
                },
                child: Text("SetPlaybackSpeed 1"),
              ),
              // Button to set playback speed to half (0.5x)
              TextButton(
                onPressed: () {
                  _controller?.setPlaybackSpeed(0.5);
                },
                child: Text("SetPlaybackSpeed 0.5"),
              ),*/
                    ],
                  )
                  : null,
        );
      },
    );
  }
}
