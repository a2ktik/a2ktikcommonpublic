import 'package:festenao_lyrics_player/lyrics_player.dart';
import 'package:flutter/material.dart';

import 'kar_controller.dart';

/// Karaoke lyrics view
class KarLyricsView extends StatefulWidget {
  /// Style for the karaoke lyrics
  final LyricsDataPlayerStyle style;

  /// Controller for karaoke
  final KarController controller;

  /// Constructor for [KarLyricsView]
  const KarLyricsView({
    super.key,
    required this.controller,
    required this.style,
  });

  @override
  State<KarLyricsView> createState() => _KarLyricsViewState();
}

class _KarLyricsViewState extends State<KarLyricsView> {
  KarController get controller => widget.controller;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: controller.ready,
      builder: (context, snapshot) {
        if (snapshot.data != true) {
          return Container();
        }

        return LyricsDataPlayer(
          controller: controller.lyricsDataController,
          style: widget.style,
        );
      },
    );
  }
}
