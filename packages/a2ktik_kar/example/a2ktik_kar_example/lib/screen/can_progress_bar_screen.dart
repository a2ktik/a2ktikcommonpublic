// ignore: implementation_imports
import 'package:a2ktik_kar/src/can_progress_bar.dart'; // Import the CanProgressBar
import 'package:flutter/material.dart';

class CanAnimationPage extends StatefulWidget {
  const CanAnimationPage({super.key});

  @override
  State<CanAnimationPage> createState() => _CanAnimationPageState();
}

class _CanAnimationPageState extends State<CanAnimationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
      setState(() {}); // Rebuild the widget as the animation progresses
    });

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Can Animation')),
      body: Center(
        child: CanProgressBar(
          progress: _animation.value,
          width: 100,
          height: 200,
          backgroundColor: Colors.grey[300]!,
          fillColor: Colors.blue,
          waveColor: Colors.blue.shade700,
        ),
      ),
    );
  }
}
