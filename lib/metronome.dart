import 'dart:math' as math;
import 'dart:async';
import 'package:pendulo/data.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:soundpool/soundpool.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class MetronomeBar extends StatefulWidget {
  const MetronomeBar({ Key? key }) : super(key: key);

  @override
  State<MetronomeBar> createState() => _MetronomeBarState();
}

class _MetronomeBarState extends State<MetronomeBar> {
  final _minTempo = 30;
  final _maxTempo = 300;

  final _tapTimes = <int>[];

  int _tempo = 60;

  MetronomeState _metronomeState = MetronomeState.stopped;
  int lastFrameTime = 0;
  Timer? _tickTimer;
  Timer? _frameTimer;
  int _lastEvenTick = 0;
  bool _lastTickWasEven = false;
  int _tickInterval = 16;

  _MetronomeBarState();

  @override
  void dispose() {
    _frameTimer?.cancel();
    _tickTimer?.cancel();
    super.dispose();
  }

  void _start() {
    _metronomeState = MetronomeState.playing;

    double bps = _tempo / 60;
    _tickInterval = 1000 ~/ bps;
    _lastEvenTick = DateTime.now().millisecondsSinceEpoch;
    _tickTimer = Timer.periodic(Duration(milliseconds: _tickInterval), _onTick);
    // _animationLoop();

    SystemSound.play(SystemSoundType.click);

    if (mounted) setState((){});
  }

  void _onTick(Timer t) {
    _lastTickWasEven = t.tick%2 == 0;
    if (_lastTickWasEven) _lastEvenTick = DateTime.now().millisecondsSinceEpoch;

    if (_metronomeState == MetronomeState.playing) {
      SystemSound.play(SystemSoundType.click);
    }
    else if (_metronomeState == MetronomeState.stopping) {
      _tickTimer?.cancel();
      _metronomeState = MetronomeState.stopped;
    }
  }

  void _stop() {
    _metronomeState = MetronomeState.stopping;
    if (mounted) setState((){});
  }

  void _tap() {
    if (_metronomeState != MetronomeState.stopped) {
      return;
    }
    int now= DateTime.now().millisecondsSinceEpoch;
    _tapTimes.add(now);
    if (_tapTimes.length > 3) {
      _tapTimes.removeAt(0);
    }
    int tapCount = 0;
    int tapIntervalSum = 0;

    for (int i = _tapTimes.length-1; i >= 1; i--) {
      int currentTapTime = _tapTimes[i];
      int previousTapTime = _tapTimes[i-1];
      int currentInterval = currentTapTime - previousTapTime;
      if (currentInterval > 3000) break;

      tapIntervalSum += currentInterval;
      tapCount++;
    }
    if (tapCount > 0) {
      int msBetweenTicks = tapIntervalSum ~/ tapCount;
      double bps = 1000/msBetweenTicks;
      _tempo = math.min(math.max((bps * 60).toInt(), _minTempo),_maxTempo);
    }
    if(mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 16,
      decoration: BoxDecoration(
          color: const Color(0xCC222222),
          borderRadius: BorderRadius.circular(2)
      )
    );
  }
}

// Controls audio playback of the metronome
class ClickTrack {
  MetronomeState metronomeState = MetronomeState.stopped;
  Timer? tickTimer;
  Meter meter = Meter();
  List<String> samples = [
    'Perc_Can_hi.wav',
    'Perc_Can_lo.wav',
    'Perc_Clackhead_lo.wav',
  ];
  Soundpool pool = Soundpool.fromOptions(
    options: const SoundpoolOptions(maxStreams: 1),
  );

  ClickTrack() {
    double bps = meter.beatsPerMinute / 60;
    int tickInterval = 1000 ~/ bps;
    tickTimer = Timer.periodic(Duration(milliseconds: tickInterval), _onTick);
  }

  ClickTrack.standard(this.metronomeState, this.meter, this.samples) {
    double bps = meter.beatsPerMinute / 60;
    int tickInterval = 1000 ~/ bps;
    tickTimer = Timer.periodic(Duration(milliseconds: tickInterval), _onTick);
  }

  void _onTick(Timer t) async {
    if (metronomeState == MetronomeState.playing) {
      int soundId = await rootBundle.load(
          "assets/audio_samples/Perc_Can_hi.wav").then((
          ByteData soundData) {
        return pool.load(soundData);
      });
      int streamId = await pool.play(soundId);
    } else if (metronomeState == MetronomeState.stopping) {
      tickTimer?.cancel();
      metronomeState = MetronomeState.stopped;
    }
  }
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
  int beatsPerMinute = 100;
  // The durational pattern, or subdivison of the the click track.
  Subdivision subdivision = Subdivision.quarter;
  // Modulates audio playback, contains sample and beat frequency.

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
}

// Polymeter arrangement containing two meters with varying
// number of beats over the same duration.
class MetronomePolymeter extends Meter {
  int numBeats2 = 4;
  int beatsPerMinute2 = 100;
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
  const MetronomeComponent({ Key? key, required this.meter, required this.clickTrack }) : super(key: key);

  final Meter meter;
  final ClickTrack clickTrack;

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

  timeSignaturePicker(BuildContext context) {
    Picker(
      adapter: NumberPickerAdapter(data: [
        NumberPickerColumn(
          initValue: widget.meter.numBeats,
          begin: 2,
          end: 63
        ),
        NumberPickerColumn(
          initValue: widget.meter.beatDuration,
          items: [
            2, 4, 8, 16, 32
          ],
        ),
      ]),
      delimiter: [
        PickerDelimiter(child: Container(
          width: 30.0,
          alignment: Alignment.center,
          child: const Icon(Icons.more_vert),
        ))
      ],
      hideHeader: true,
      cancelText: 'CANCEL',
      confirmText: 'CONFIRM',
      title: const Text("Time signature:"),
      onConfirm: (Picker picker, List value) {
        setState(() {
          widget.meter.numBeats = picker.getSelectedValues()[0];
          widget.meter.beatDuration = picker.getSelectedValues()[1];
          widget.clickTrack.meter = widget.meter;
        });
      }
    ).showDialog(context);
  }

  tempoPicker(BuildContext context) {
    Picker(
      adapter: NumberPickerAdapter(data: [
        NumberPickerColumn(
          initValue: widget.meter.beatsPerMinute,
          jump: 5,
          begin: 30,
          end: 300
        ),
      ]),
      hideHeader: true,
      cancelText: 'CANCEL',
      confirmText: 'CONFIRM',
      title: const Text("Beats per minute:"),
      onConfirm: (Picker picker, List value) {
        setState(() {
          widget.meter.beatsPerMinute = picker.getSelectedValues()[0];
          widget.clickTrack.meter = widget.meter;
        });
      }
    ).showDialog(context);
  }

  subdivisionPicker(BuildContext context) {
    Picker(
      selecteds: <int>[
        widget.meter.subdivision.index,
      ],
      adapter: PickerDataAdapter<String>(
        pickerdata: <String>[
          'Quarter notes',
          'Eighth notes',
          'Triplets',
          'Sixteenth notes',
        ]
      ),
      hideHeader: true,
      cancelText: 'CANCEL',
      confirmText: 'CONFIRM',
      title: const Text("Durational pattern:"),
      onConfirm: (Picker picker, List value) {
        setState(() {
          String s = picker.getSelectedValues()[0];
          switch (s) {
            case 'Quarter notes':
              widget.meter.subdivision = Subdivision.quarter;
              widget.clickTrack.meter = widget.meter;
              break;
            case 'Eighth notes':
              widget.meter.subdivision = Subdivision.eighth;
              widget.clickTrack.meter = widget.meter;
              break;
            case 'Triplets':
              widget.meter.subdivision = Subdivision.triplet;
              widget.clickTrack.meter = widget.meter;
              break;
            case 'Sixteenth notes':
              widget.meter.subdivision = Subdivision.sixteenth;
              widget.clickTrack.meter = widget.meter;
              break;
          }
        });
      }
    ).showDialog(context);
  }

  Color barColor = const Color(0xCC222222);
  IconData buttonIcon = Icons.play_arrow;
  Color buttonColor = const Color(0xDD28ED74);

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
                  SizedBox(
                    width: 44,
                    height: 90,
                    child: FloatingActionButton(
                      onPressed: () async {
                        setState(() {
                          if (widget.clickTrack.metronomeState == MetronomeState.stopped) {
                            buttonIcon = Icons.pause;
                            buttonColor = const Color(0xDDF0BE1A);
                            widget.clickTrack.metronomeState = MetronomeState.playing;
                          } else if (widget.clickTrack.metronomeState == MetronomeState.playing) {
                            buttonIcon = Icons.play_arrow;
                            buttonColor = const Color(0xDD28ED74);
                            widget.clickTrack.metronomeState = MetronomeState.stopped;
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
                        color: const Color(0xFF333333),
                      ),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.all(7)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          timeSignaturePicker(context);
                        },
                        child: SizedBox(
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
                                  TextSpan(text:
                                  '${convertSignature(widget.meter.numBeats)}\n'),
                                  TextSpan(text:
                                  convertSignature(widget.meter.beatDuration)),
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
                      ),
                      const Padding(padding: EdgeInsets.all(5)),
                      GestureDetector(
                        onTap: () {
                          tempoPicker(context);
                        },
                        child: SizedBox(
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
                      ),
                      const Padding(padding: EdgeInsets.all(5)),
                      GestureDetector(
                        onTap: () {
                          subdivisionPicker(context);
                        },
                        child: SizedBox(
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
                      ),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.all(6.3)),
                  SizedBox(
                    width: 44,
                    height: 90,
                    child: FloatingActionButton(
                      onPressed: () => showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text("Delete or reset meter?"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'CANCEL'),
                              child: const Text('CANCEL'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, 'RESET');
                                setState(() {
                                  widget.meter.numBeats = 4;
                                  widget.meter.beatDuration = 4;
                                  widget.meter.beatsPerMinute = 100;
                                  widget.meter.subdivision = Subdivision.quarter;
                                  widget.clickTrack.metronomeState = MetronomeState.stopped;
                                  widget.clickTrack.meter = widget.meter;
                                });
                              },
                              child: const Text('RESET'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, 'DELETE');
                                if(mounted) {
                                  print("mounted");
                                } else {
                                  print("unmounted");
                                }
                                dispose();
                              },
                              child: const Text('DELETE'),
                            ),
                          ],
                        ),
                      ),
                      backgroundColor: const Color(0xFF333333),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2)
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 40,
                        color: Color(0xDDEE2222),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 16,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(2)
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
