// ignore_for_file: avoid_print

import 'package:festenao_lyrics_player/lyrics_player.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> main() async {
  test('lrc', () {
    var lrc =
        '[00:06.388]<00:06.388>Il <00:06.808>en <00:06.988>faut <00:07.508>peu <00:07.958>pour <00:08.348>ê-<00:08.508>tre <00:08.708>heu-<00:08.958>reux';
    var data = parseLyricLrc(lrc);
    var line = data.lines.first;
    print(line);
    for (var part in line.parts) {
      print(part);
    }
    print(data);
  });
}
