import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

enum Subdivision {
  quarter,
  eighth,
  triplet,
  sixteenth,
}

// Base class for all shared subclass features.
class Meter {
  // The numerator part of the time signature, denotes the number of
  // beats played per bar/measure.
  int numBeats = 4;
  // The 'denominator' part, indicating the type of note being played;
  // e.g. 4 for quarter note, 8 for eighth, etc.
  int beatDuration = 4;
  // Tempo of the time signature.
  double beatsPerMinute = 100;
  // The durational pattern, or subdivison of the the click track.
  Subdivision subdivision = Subdivision.quarter;
  // Modulates audio playback, contains sample and beat frequency.
  AudioCache? audioCache = AudioCache(
    prefix: 'assets/audio_samples/',
    fixedPlayer: AudioPlayer(
        mode: PlayerMode.LOW_LATENCY
    ),
  );

  Meter();
  Meter.standard(this.numBeats, this.beatDuration, this.beatsPerMinute,
      this.subdivision);
}

// Standard meter, will not have many additional properties
// or functionality over superclass.
class MetronomeMeter extends Meter {}

// Polyrhythm sequence which will have two agonist beats
// over the same subdivision.
class MetronomePolyrhythm extends Meter {
  int numBeats2 = 3;
  AudioCache? audioCache2 = AudioCache(
    prefix: 'assets/audio_samples/',
    fixedPlayer: AudioPlayer(
      mode: PlayerMode.LOW_LATENCY
    ),
  );
}

// Polymeter arrangement containing two meters with varying
// number of beats over the same duration.
class MetronomePolymeter extends Meter {
  int numBeats2 = 4;
  double beatsPerMinute2 = 100.0;
  AudioCache? audioCache2 = AudioCache(
    prefix: 'assets/audio_samples/',
    fixedPlayer: AudioPlayer(
      mode: PlayerMode.LOW_LATENCY
    ),
  );
}

// Widget for visualizing the beats.
class MetronomeVisualizer extends StatefulWidget {
  const MetronomeVisualizer({ Key? key, required this.meter,
    this.animationDuration = const Duration(milliseconds: 1666) }) :
      super(key: key);

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
        // width: 136.0,
        // height: 86.0,
        decoration: BoxDecoration(
          color: const Color(0xCC202020),
          borderRadius: BorderRadius.circular(2)
        ),
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
    widget.meter.audioCache?.loadAll([
      'Perc_Stick_hi.wav',
      'Perc_Stick_lo.wav'
    ]);
  }

  @override
  void didUpdateWidget(MetronomeComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }

  final sample = 'Perc_Stick_hi.wav';

  IconData buttonIcon = Icons.play_arrow;
  Color buttonColor = const Color(0xDD28ED74);
  PlayerState playerState = PlayerState.PAUSED;

  void controlPlayer(AudioPlayer player) {

  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 82,
              decoration: BoxDecoration(
                color: const Color(0xCC555555),
                borderRadius: BorderRadius.circular(2)
              ),
              child: Row(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: SizedBox(
                      width: 52,
                      height: 90,
                      child: FloatingActionButton(
                        onPressed: () async {
                          /*
                          final player = await widget.meter.audioCache?.loop(
                              'Perc_Stick_hi.wav'
                          );*/
                          setState(() {
                            if (playerState == PlayerState.PAUSED) {
                              buttonIcon = Icons.pause;
                              buttonColor = const Color(0xDDF0BE1A);
                              playerState = PlayerState.PLAYING;
                              while(playerState == PlayerState.PLAYING) {
                                final player = widget.meter.audioCache?.play(
                                  'Perc_Stick_hi.wav'
                                );
                              }
                              // player?.play(sample);
                            } else if (playerState == PlayerState.PLAYING) {
                              buttonIcon = Icons.play_arrow;
                              buttonColor = const Color(0xDD28ED74);
                              playerState = PlayerState.PAUSED;
                              final player = widget.meter.audioCache?.play(
                                'empty.wav'
                              );
                              int result =  player?.pause();
                            }
                          });
                        },
                        backgroundColor: buttonColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2)
                        ),
                        child: Icon(
                          buttonIcon,
                          size: 40,
                          color: const Color(0xFF404040),
                        ),
                      ),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.all(12)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 62,
                        height: 74,
                        child: Container(
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
                                fontSize: 54,
                                fontFamily: 'Bravura',
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const Padding(padding: EdgeInsets.all(5)),
                      SizedBox(
                        width: 86,
                        height: 42,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                              color: const Color(0xCC333333),
                              borderRadius: BorderRadius.circular(2)
                          ),
                          child: Text.rich(
                            TextSpan(
                              children: <TextSpan>[
                                TextSpan(text: '\n\uE1D5\t=  '
                                    '${widget.meter.beatsPerMinute.toStringAsFixed(0)}'),
                              ],
                              style: const TextStyle(
                                height: 0.175,
                                letterSpacing: -0.5,
                                fontSize: 24,
                                fontFamily: 'Bravura',
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const Padding(padding: EdgeInsets.all(5)),
                      SizedBox(
                        width: 78,
                        height: 42,
                        child:
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                              color: const Color(0xCC333333),
                              borderRadius: BorderRadius.circular(2)
                          ),
                          child: Text.rich(
                            TextSpan(
                              children: <TextSpan>[
                                TextSpan(text:
                                '\n${convertSubdivison(widget.meter.subdivision)}'),
                              ],
                              style: const TextStyle(
                                height: 0.175,
                                letterSpacing: -0.5,
                                fontSize: 24,
                                fontFamily: 'Bravura',
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 350,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xCC222222),
                borderRadius: BorderRadius.circular(2)
              ),
              child: MetronomeVisualizer(
                meter: widget.meter,
              ),
            ),
          ],
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

String convertSubdivison(Subdivision s) {
  switch (s) {
    case Subdivision.quarter:
      return String.fromCharCodes([0xE1F0]);
    case Subdivision.eighth:
      return String.fromCharCodes([0xE1F0, 0xE1F7, 0xE1F2]);
    case Subdivision.triplet:
      return String.fromCharCodes([0xE1F0, 0xE1F7, 0xE1F2,
        0xE1FF, 0xE1F7, 0xE1F2]);
    case Subdivision.sixteenth:
      return String.fromCharCodes([0xE1F0, 0xE1F7, 0xE1F2,
        0xE1F7, 0xE1F2, 0xE1F7, 0xE1F2]);
    default:
      debugPrint('unknown subdivison value: $s');
      return "";
  }
}
