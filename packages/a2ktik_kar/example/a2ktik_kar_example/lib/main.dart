import 'package:a2ktik_kar_example/screen/can_progress_bar_screen.dart';
import 'package:a2ktik_kar_example/screen/play_audio_screen.dart';
import 'package:festenao_media_base_app/festenao_widget.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  webSplashReady();
  sleep(300).then((_) {
    webSplashHide();
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Karaoke Demo',
      theme: poppinsThemeData1(),
      home: const MyHomePage(title: 'Karaoke demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    sleep(0).then((_) {
      // ignore: dead_code
      if (false) {
        //if (devWarning(true) && kDebugMode) {
        if (mounted) {
          goToCanScreen(context);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            const SizedBox(height: 20),
            BodyContainer(
              child: TilePadding(
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      goToAudioPlayer(context);
                    },
                    child: const Text('Karaoke audio demo'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            BodyContainer(
              child: TilePadding(
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      goToCanScreen(context);
                    },
                    child: const Text('Can animation demo'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void goToAudioPlayer(BuildContext context) {
    ContentNavigator.pushBuilder<void>(
      context,
      builder:
          (context) => const AudioKaraokePlayer(
            params: AudioKaraokeParams(
              title: 'Test',
              audioId: assetAudioExample1,
              lrcId: assetLyricsExample1,
              start: Duration(seconds: 6),
            ),
          ),
    );
  }

  void goToCanScreen(BuildContext context) {
    ContentNavigator.pushBuilder<void>(
      context,
      builder: (context) => const CanAnimationPage(),
    );
  }
}
