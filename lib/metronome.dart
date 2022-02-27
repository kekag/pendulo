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

// Widget for representing metronome controls and visualization.
class MetronomeComponent extends StatefulWidget {
  final Meter meter;

  MetronomeComponent(this.meter);

  @override
  _MetronomeComponentState createState() => _MetronomeComponentState(meter);
}

// State of metronome component widgets.
class _MetronomeComponentState extends State<MetronomeComponent>
    with TickerProviderStateMixin {
  Meter meter;

  _MetronomeComponentState(this.meter);

  Widget get dogImage {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 256.0,
      decoration: const BoxDecoration(
        shape: BoxShape.rectangle,
      ),
    );
  }

  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 10),
    vsync: this,
  )..repeat();

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
        return Transform.rotate(
          angle: _controller.value * 2.0 * math.pi,
          child: child,
        );
      },
    );
  }
}