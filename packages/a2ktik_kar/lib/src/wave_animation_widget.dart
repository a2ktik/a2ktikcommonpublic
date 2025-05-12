import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A widget that displays a simple, continuous wave animation.
///
/// The animation duration can be specified directly or calculated automatically
/// based on a target scroll speed and the widget's width.
class WaveAnimationWidget extends StatefulWidget {
  /// The color of the wave.
  final Color waveColor;

  /// The height of the wave.
  final double waveHeight;

  /// Controls the number of 2*PI phase shifts per animation cycle if `animationDuration` is specified.
  /// Must be an integer (e.g., 1.0, 2.0) for a smooth, non-jumping loop.
  /// Defaults to 1.0.
  /// This parameter is ignored if `animationDuration` is null and `targetScrollSpeedPps` is used
  /// for auto-duration calculation (in which case, an internal wave speed of 1.0 is used for smoothness).
  final double waveSpeed;

  /// The frequency of the wave. Higher values mean more crests and troughs visible on screen.
  final double waveFrequency;

  /// The duration of one complete animation controller cycle.
  /// If null, and `targetScrollSpeedPps` and `widthForDurationCalculation` are provided,
  /// the duration will be calculated automatically.
  final Duration? animationDuration;

  /// Target visual speed of the wave in pixels per second.
  /// Used for auto-calculating `animationDuration` if `animationDuration` is null.
  /// Requires `widthForDurationCalculation` to be set.
  final double? targetScrollSpeedPps;

  /// The width of the widget, required for auto-calculating `animationDuration`
  /// based on `targetScrollSpeedPps`. Typically obtained from a LayoutBuilder.
  final double? widthForDurationCalculation;

  /// Creates a [WaveAnimationWidget].
  const WaveAnimationWidget({
    super.key, // Consider using a ValueKey if widthForDurationCalculation can change, to re-init state.
    this.waveColor = Colors.blueAccent,
    this.waveHeight = 20.0,
    this.waveSpeed = 1.0,
    this.waveFrequency = 1.5,
    this.animationDuration,
    this.targetScrollSpeedPps,
    this.widthForDurationCalculation,
  });

  @override
  State<WaveAnimationWidget> createState() => _WaveAnimationWidgetState();
}

class _WaveAnimationWidgetState extends State<WaveAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late double _effectiveWaveSpeed;
  late Duration _actualDuration;

  @override
  void initState() {
    super.initState();
    _updateAnimationParameters(); // Calculate initial parameters
    _controller = AnimationController(vsync: this, duration: _actualDuration)
      ..repeat(); // Repeat the animation indefinitely
  }

  @override
  void didUpdateWidget(WaveAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if parameters that affect duration or effectiveWaveSpeed have changed
    if (widget.animationDuration != oldWidget.animationDuration ||
        widget.targetScrollSpeedPps != oldWidget.targetScrollSpeedPps ||
        widget.widthForDurationCalculation !=
            oldWidget.widthForDurationCalculation ||
        widget.waveSpeed != oldWidget.waveSpeed) {
      // Store old controller state
      final wasAnimating = _controller.isAnimating;
      final oldValue = _controller.value;

      _updateAnimationParameters(); // Recalculate based on new widget properties

      _controller.duration = _actualDuration; // Update controller's duration

      // If the controller was running, we want to resume it smoothly.
      // Setting the duration might cause it to pick up on the next loop.
      // For a more immediate change while trying to maintain visual continuity:
      if (wasAnimating) {
        _controller.stop(); // Stop with current value
        _controller.value = oldValue; // Restore old value before restarting
        _controller.repeat(); // Start again with new duration
      }
    }
  }

  /// Calculates or sets the `_actualDuration` and `_effectiveWaveSpeed`
  /// based on the widget's properties.
  void _updateAnimationParameters() {
    if (widget.animationDuration == null &&
        widget.targetScrollSpeedPps != null &&
        widget.targetScrollSpeedPps! > 0 &&
        widget.widthForDurationCalculation != null &&
        widget.widthForDurationCalculation! > 0) {
      // Auto-calculate duration and ensure smooth wave speed.
      // In this mode, _effectiveWaveSpeed is forced to 1.0 to guarantee smoothness.
      // This means one full 2*PI phase cycle occurs over the calculated duration.
      _effectiveWaveSpeed = 1.0;

      final durationInSeconds =
          (widget.widthForDurationCalculation! *
              _effectiveWaveSpeed) / // Use _effectiveWaveSpeed (1.0)
          widget.targetScrollSpeedPps!;

      if (durationInSeconds <= 0 || !durationInSeconds.isFinite) {
        // Fallback if calculation is invalid (e.g., speed is 0 or width is 0)
        _actualDuration = const Duration(seconds: 2);
      } else {
        _actualDuration = Duration(
          milliseconds: (durationInSeconds * 1000).round(),
        );
      }
    } else {
      // User provides duration, or not enough info for auto-calculation.
      // Use widget.waveSpeed as is. User is responsible for it being an integer for smoothness.
      _effectiveWaveSpeed = widget.waveSpeed;
      _actualDuration =
          widget.animationDuration ??
          const Duration(seconds: 2); // Default if null
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          // The CustomPaint widget allows us to draw custom graphics
          painter: _WavePainter(
            animationValue:
                _controller.value, // Current animation progress (0.0 to 1.0)
            waveColor: widget.waveColor,
            waveHeight: widget.waveHeight,
            waveSpeed:
                _effectiveWaveSpeed, // Use the calculated or set effective speed
            waveFrequency: widget.waveFrequency,
          ),
          child: Container(), // The painter will draw onto this container
        );
      },
    );
  }
}

/// Custom painter for drawing the wave. (No changes from previous version)
class _WavePainter extends CustomPainter {
  final double animationValue; // Normalized animation value (0.0 to 1.0)
  final Color waveColor;
  final double waveHeight;
  final double waveSpeed; // This is the _effectiveWaveSpeed from the state
  final double waveFrequency;

  _WavePainter({
    required this.animationValue,
    required this.waveColor,
    required this.waveHeight,
    required this.waveSpeed,
    required this.waveFrequency,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = waveColor
          ..style = PaintingStyle.fill;

    final path = Path();

    // Start the path from the bottom-left
    path.moveTo(0, size.height);

    // Calculate wave properties
    // The wave moves horizontally based on animationValue and waveSpeed.
    // waveSpeed here is _effectiveWaveSpeed, which should be an integer for smooth loops.
    final horizontalShift = animationValue * size.width * waveSpeed;

    for (double x = 0; x <= size.width; x++) {
      // Calculate the y-coordinate of the wave at this x position
      // This uses a sine function to create the wave shape
      // - waveFrequency controls how many waves are visible
      // - horizontalShift creates the animation effect (phase shift)
      // - waveHeight controls the amplitude of the wave
      final y =
          size.height -
          (math.sin(
                    (x /
                            size.width *
                            2 *
                            math.pi *
                            waveFrequency) - // Spatial component
                        (horizontalShift / size.width * 2 * math.pi),
                  ) * // Animation phase shift
                  waveHeight +
              waveHeight); // Offset to ensure wave is drawn from bottom and positive amplitude

      path.lineTo(x, y);
    }

    // Close the path to the bottom-right
    path.lineTo(size.width, size.height);
    // Close the path back to the start (bottom-left)
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    // Repaint whenever the animation value changes, or if any wave properties change
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.waveColor != waveColor ||
        oldDelegate.waveHeight != waveHeight ||
        oldDelegate.waveSpeed != waveSpeed ||
        oldDelegate.waveFrequency != waveFrequency;
  }
}

// Example Usage:
// To use this widget, you can add it to your Flutter app's widget tree.
// If you want to use auto-duration calculation, wrap it in a LayoutBuilder.

void main() {
  runApp(const MyApp());
}

/// A simple Flutter app demonstrating the WaveAnimationWidget.
class MyApp extends StatelessWidget {
  /// Creates a new instance of MyApp.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Wave Animation Demo')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Wave with Specified Duration:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                height: 150,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const WaveAnimationWidget(
                  waveColor: Colors.teal,
                  waveHeight: 25.0,
                  waveSpeed: 1.0, // Integer for smooth loop
                  waveFrequency: 2.0,
                  animationDuration: Duration(seconds: 3),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Wave with Auto-Calculated Duration (50 pps):',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                height: 150,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                // Use LayoutBuilder to get the width for calculation
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return WaveAnimationWidget(
                      // Using ValueKey ensures the widget re-initializes if width changes,
                      // which is important if constraints change dynamically.
                      key: ValueKey(constraints.maxWidth),
                      waveColor: Colors.deepPurpleAccent,
                      waveHeight: 20.0,
                      waveFrequency: 1.2,
                      // waveSpeed is ignored here because duration is auto-calculated
                      // targetScrollSpeedPps will use an internal waveSpeed of 1.0.
                      targetScrollSpeedPps: 450.0, // Pixels per second
                      widthForDurationCalculation: constraints.maxWidth,
                      // animationDuration is null, so it will be calculated
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Faster Wave with Auto-Calculated Duration (150 pps):',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                height: 100, // Different height
                width: 250, // Fixed width example
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const WaveAnimationWidget(
                  waveColor: Colors.orange,
                  waveHeight: 5.0,
                  waveFrequency: 2.5,
                  //waveSpeed: 1.2,
                  targetScrollSpeedPps: 600.0,
                  widthForDurationCalculation:
                      250, // Fixed width provided directly
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
