import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

// Base class for all shared subclass features.
class Meter {
  // The numerator part of the time signature, denotes
  // the number of beats played per bar/measure.
  int numBeats = 4;
  // The 'denominator' part, indicating the type of note
  // being played; e.g. 4 for quarter note, 8 for eighth, etc.
  int beatDuration = 4;
  // Tempo of the time signature.
  double beatsPerMinute = 100.0;
  // Modulates audio playback, contains sample and beat
  // frequency.
  AudioPlayer? clickTrack;

  Meter();
  Meter.standard(this.numBeats, this.beatDuration, this.beatsPerMinute);
}

// Standard meter, will not have many additional properties
// or functionality over superclass.
class MetronomeMeter extends Meter {}

// Polyrhythm sequence which will have two agonist beats
// over the same subdivision.
class MetronomePolyrhythm extends Meter {
  int numBeats2 = 3;
  AudioPlayer? clickTrack2;
}

// Polymeter arrangement containing two meters with varying
// number of beats over the same duration.
class MetronomePolymeter extends Meter {
  int numBeats2 = 4;
  double beatsPerMinute2 = 100.0;
  AudioPlayer? clickTrack2;
}

// Widget for visualizing the beats.
class MetronomeVisualizer extends StatefulWidget {
  const MetronomeVisualizer({ Key? key, required this.meter,
    this.animationDuration = const Duration(milliseconds: 1666) }) : super(key: key);

  final Meter meter;
  final Duration animationDuration;

  @override
  State<MetronomeVisualizer> createState() => _MetronomeVisualizerState();
}

// State of metronome component widgets.
class _MetronomeVisualizerState extends State<MetronomeVisualizer>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, // TickerProviderStateMixin
      duration: widget.animationDuration,
    );
  }

  @override
  void didUpdateWidget(MetronomeVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.animationDuration;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: Container(
        width: 200.0,
        height: 200.0,
        color: Colors.green,
        child: const Center(
          child: Text('Whee!'),
        ),
      ),
      builder: (BuildContext context, Widget? child) {
        return Transform.translate(
          offset: const Offset(10.0, 0.0),
          child: child,
        );
      },
    );
  }
}

// Widget for controlling metronome properties, audio playback, and visualization.
class MetronomeComponent extends StatefulWidget {
  const MetronomeComponent({ Key? key, required this.meter }) : super(key: key);

  final Meter meter;

  @override
  State<MetronomeComponent> createState() => _MetronomeComponentState();
}

// State of metronome component widgets.
class _MetronomeComponentState extends State<MetronomeComponent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(MetronomeComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xCC555555),
            borderRadius: BorderRadius.circular(2)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xCC333333),
                  borderRadius: BorderRadius.circular(2)
                ),
                child: Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(text: '${convertSignature(widget.meter.numBeats)}\n'),
                      TextSpan(text: convertSignature(widget.meter.beatDuration)),
                    ],
                    style: const TextStyle(
                      height: 0.55,
                      letterSpacing: -1,
                      fontSize: 64,
                      fontFamily: 'Bravura',
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Padding(padding: EdgeInsets.all(6)),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xCC333333),
                  borderRadius: BorderRadius.circular(2)
                ),
                child: Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(text: '\uE1D5\t=  '
                        '${widget.meter.beatsPerMinute.toStringAsFixed(0)}'),
                    ],
                    style: const TextStyle(
                      height: 0.6,
                      letterSpacing: -0.5,
                      fontSize: 24,
                      fontFamily: 'Bravura',
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String convertSignature(int i) {
  if (i >= 100) {
    debugPrint('cannot handle signature of $i (>100)');
    return "";
  }
  int div = i ~/ 10;
  if (div > 0) {
    int tens = 0xE080 + div;
    int ones = 0xE080 + (i % 10);
    return String.fromCharCodes([tens, ones]);
  }
  return String.fromCharCode(0xE080 + i);
}