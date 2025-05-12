// ignore_for_file: public_member_api_docs

import 'dart:math' as math;

import 'package:flutter/material.dart';

class CanProgressBar extends StatelessWidget {
  final double progress;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color fillColor;
  final Color waveColor;

  const CanProgressBar({
    super.key,
    required this.progress,
    required this.width,
    required this.height,
    required this.backgroundColor,
    required this.fillColor,
    required this.waveColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _CanPainter(
          progress: progress,
          backgroundColor: backgroundColor,
          fillColor: fillColor,
          waveColor: waveColor,
        ),
      ),
    );
  }
}

class _CanPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color fillColor;
  final Color waveColor;

  _CanPainter({
    required this.progress,
    required this.backgroundColor,
    required this.fillColor,
    required this.waveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final canRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(10.0),
    );

    final backgroundPaint = Paint()..color = backgroundColor;
    canvas.drawRRect(canRect, backgroundPaint);

    final fillHeight = size.height * progress;
    final fillRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height - fillHeight, size.width, fillHeight),
      const Radius.circular(10.0),
    );

    final fillPaint = Paint()..color = fillColor;
    canvas.drawRRect(fillRect, fillPaint);

    if (progress > 0) {
      final waveHeight =
          size.height *
          0.05 *
          math.min(progress, 0.5) *
          2; // Wave height based on progress, max at 0.5 progress
      final waveY = size.height - fillHeight;

      final wavePath = Path();
      wavePath.moveTo(-size.width * 0.5, waveY); // Start outside the left edge

      for (
        var i = -size.width * 0.5;
        i < size.width * 1.5;
        i += size.width / 20
      ) {
        final x = i;
        final y =
            waveY +
            waveHeight *
                math.sin(
                  (x / size.width) * 4 * math.pi + progress * math.pi * 2,
                );
        wavePath.lineTo(x, y);
      }

      wavePath.lineTo(
        size.width * 1.5,
        size.height,
      ); // Extend to bottom right outside
      wavePath.lineTo(
        -size.width * 0.5,
        size.height,
      ); // Extend to bottom left outside
      wavePath.close();

      final wavePaint = Paint()..color = waveColor;
      canvas.drawPath(wavePath, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is _CanPainter) {
      return oldDelegate.progress != progress ||
          oldDelegate.backgroundColor != backgroundColor ||
          oldDelegate.fillColor != fillColor ||
          oldDelegate.waveColor != waveColor;
    }
    return true;
  }
}
