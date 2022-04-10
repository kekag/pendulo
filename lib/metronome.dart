import 'package:pendulo/meter.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter/material.dart';

class MeterComponent extends StatefulWidget {
  const MeterComponent({ Key? key, required this.meter,
    required this.clickTrack }) : super(key: key);

  final MetronomeMeter meter;
  final ClickTrack clickTrack;

  @override
  State<MeterComponent> createState() => _MeterComponentState();
}

class _MeterComponentState extends State<MeterComponent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(MeterComponent oldWidget) {
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
      title: const Text('Time signature:'),
      onConfirm: (Picker picker, List value) {
        setState(() {
          widget.meter.numBeats = picker.getSelectedValues()[0];
          widget.meter.beatDuration = picker.getSelectedValues()[1];
          widget.clickTrack.updateMeter(widget.meter);
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
      title: const Text('Beats per minute:'),
      onConfirm: (Picker picker, List value) {
        setState(() {
          widget.meter.beatsPerMinute = picker.getSelectedValues()[0];
          widget.clickTrack.updateMeter(widget.meter);
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
      title: const Text('Durational pattern:'),
      onConfirm: (Picker picker, List value) {
        setState(() {
          String s = picker.getSelectedValues()[0];
          switch (s) {
            case 'Quarter notes':
              widget.meter.subdivision = Subdivision.quarter;
              break;
            case 'Eighth notes':
              widget.meter.subdivision = Subdivision.eighth;
              break;
            case 'Triplets':
              widget.meter.subdivision = Subdivision.triplet;
              break;
            case 'Sixteenth notes':
              widget.meter.subdivision = Subdivision.sixteenth;
              break;
          }
          widget.clickTrack.updateMeter(widget.meter);
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
                  const Padding(padding: EdgeInsets.all(6.65)),
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
                          widget.clickTrack.updateMeter(widget.meter);
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
                          widget.clickTrack.updateMeter(widget.meter);
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
                  const Padding(padding: EdgeInsets.all(6.65)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 44,
                      height: 90,
                      child: FloatingActionButton(
                        onPressed: () => showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Delete or reset meter?'),
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
                                    buttonIcon = Icons.play_arrow;
                                    buttonColor = const Color(0xDD28ED74);
                                    widget.clickTrack.metronomeState = MetronomeState.stopped;
                                  });
                                },
                                child: const Text('RESET'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, 'DELETE');
                                  if (mounted) {
                                    debugPrint('mounted');
                                  } else {
                                    debugPrint('unmounted');
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
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 40,
                          color: Color(0xDDEE2222),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 16,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PolyrhythmComponent extends StatefulWidget {
  const PolyrhythmComponent({ Key? key, required this.meter,
    required this.clickTrack }) : super(key: key);

  final MetronomePolyrhythm meter;
  final ClickTrack clickTrack;

  @override
  State<PolyrhythmComponent> createState() => _PolyrhythmComponentState();
}

class _PolyrhythmComponentState extends State<PolyrhythmComponent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(PolyrhythmComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }

  numBeatsPicker1(BuildContext context) {
    Picker(
      adapter: NumberPickerAdapter(data: [
        NumberPickerColumn(
          initValue: widget.meter.numBeats,
          begin: 2,
          end: 32
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
      title: const Text('First rhythm:'),
      onConfirm: (Picker picker, List value) {
        setState(() {
          widget.meter.numBeats = picker.getSelectedValues()[0];
          widget.clickTrack.updateMeter(widget.meter);
        });
      }
    ).showDialog(context);
  }

  numBeatsPicker2(BuildContext context) {
    Picker(
        adapter: NumberPickerAdapter(data: [
          NumberPickerColumn(
            initValue: widget.meter.numBeats,
            begin: 2,
            end: 32
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
        title: const Text('Second rhythm:'),
        onConfirm: (Picker picker, List value) {
          setState(() {
            widget.meter.numBeats2 = picker.getSelectedValues()[0];
            widget.clickTrack.updateMeter(widget.meter);
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
      title: const Text('Beats per minute:'),
      onConfirm: (Picker picker, List value) {
        setState(() {
          widget.meter.beatsPerMinute = picker.getSelectedValues()[0];
          widget.clickTrack.updateMeter(widget.meter);
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
                  const Padding(padding: EdgeInsets.all(9)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          numBeatsPicker1(context);
                        },
                        child: SizedBox(
                          width: 62,
                          height: 62,
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
                                  convertSignature(widget.meter.numBeats)),
                                ],
                                style: const TextStyle(
                                  height: 0.84,
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
                      const Padding(padding: EdgeInsets.all(1)),
                      const Text(
                        '/',
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                      const Padding(padding: EdgeInsets.all(0.75)),
                      GestureDetector(
                        onTap: () {
                          numBeatsPicker2(context);
                        },
                        child: SizedBox(
                          width: 62,
                          height: 62,
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xCC333333),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text.rich(
                              TextSpan(
                                children: <TextSpan>[
                                  TextSpan(text:
                                  convertSignature(widget.meter.numBeats2)),
                                ],
                                style: const TextStyle(
                                  height: 0.84,
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
                          widget.clickTrack.updateMeter(widget.meter);
                        },
                        child: SizedBox(
                          width: 86,
                          height: 42,
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xCC333333),
                              borderRadius: BorderRadius.circular(2),
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
                    ],
                  ),
                  const Padding(padding: EdgeInsets.all(9)),
                  SizedBox(
                    width: 44,
                    height: 90,
                    child: FloatingActionButton(
                      onPressed: () => showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Delete or reset meter?'),
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
                                  buttonIcon = Icons.play_arrow;
                                  buttonColor = const Color(0xDD28ED74);
                                  widget.clickTrack.metronomeState = MetronomeState.stopped;
                                });
                              },
                              child: const Text('RESET'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, 'DELETE');
                                if (mounted) {
                                  debugPrint('mounted');
                                } else {
                                  debugPrint('unmounted');
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
                        borderRadius: BorderRadius.circular(2),
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
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PolymeterComponent extends StatefulWidget {
  const PolymeterComponent({ Key? key, required this.meter,
    required this.clickTrack }) : super(key: key);

  final MetronomePolymeter meter;
  final ClickTrack clickTrack;

  @override
  State<PolymeterComponent> createState() => _PolymeterComponentState();
}

class _PolymeterComponentState extends State<PolymeterComponent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(PolymeterComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }

  timeSignaturePicker1(BuildContext context) {
    Picker(
      adapter: NumberPickerAdapter(data: [
        NumberPickerColumn(
          initValue: widget.meter.numBeats,
          begin: 2,
          end: 63,
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
      title: const Text('Time signature:'),
      onConfirm: (Picker picker, List value) {
        setState(() {
          widget.meter.numBeats = picker.getSelectedValues()[0];
          widget.meter.beatDuration = picker.getSelectedValues()[1];
          widget.clickTrack.updateMeter(widget.meter);
        });
      }
    ).showDialog(context);
  }

  timeSignaturePicker2(BuildContext context) {
    Picker(
      adapter: NumberPickerAdapter(data: [
        NumberPickerColumn(
          initValue: widget.meter.numBeats2,
          begin: 2,
          end: 63,
        ),
        NumberPickerColumn(
          initValue: widget.meter.beatDuration2,
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
      title: const Text('Time signature:'),
      onConfirm: (Picker picker, List value) {
        setState(() {
          widget.meter.numBeats2 = picker.getSelectedValues()[0];
          widget.meter.beatDuration2 = picker.getSelectedValues()[1];
          widget.clickTrack.updateMeter(widget.meter);
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
            end: 300,
          ),
        ]),
        hideHeader: true,
        cancelText: 'CANCEL',
        confirmText: 'CONFIRM',
        title: const Text('Beats per minute:'),
        onConfirm: (Picker picker, List value) {
          setState(() {
            widget.meter.beatsPerMinute = picker.getSelectedValues()[0];
            widget.clickTrack.updateMeter(widget.meter);
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
                borderRadius: BorderRadius.circular(2),
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
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Icon(
                        buttonIcon,
                        size: 40,
                        color: const Color(0xFF333333),
                      ),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.all(10.6)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          timeSignaturePicker1(context);
                        },
                        child: SizedBox(
                          width: 62,
                          height: 74,
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xCC333333),
                              borderRadius: BorderRadius.circular(2),
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
                          timeSignaturePicker2(context);
                        },
                        child: SizedBox(
                          width: 62,
                          height: 74,
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xCC333333),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text.rich(
                              TextSpan(
                                children: <TextSpan>[
                                  TextSpan(text:
                                  '${convertSignature(widget.meter.numBeats2)}\n'),
                                  TextSpan(text:
                                  convertSignature(widget.meter.beatDuration2)),
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
                          widget.clickTrack.updateMeter(widget.meter);
                        },
                        child: SizedBox(
                          width: 86,
                          height: 42,
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xCC333333),
                              borderRadius: BorderRadius.circular(2),
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
                    ],
                  ),
                  const Padding(padding: EdgeInsets.all(10.6)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 44,
                      height: 90,
                      child: FloatingActionButton(
                        onPressed: () => showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Delete or reset meter?'),
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
                                    buttonIcon = Icons.play_arrow;
                                    buttonColor = const Color(0xDD28ED74);
                                    widget.clickTrack.metronomeState = MetronomeState.stopped;
                                  });
                                },
                                child: const Text('RESET'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, 'DELETE');
                                  if (mounted) {
                                    debugPrint('mounted');
                                  } else {
                                    debugPrint('unmounted');
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
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 40,
                          color: Color(0xDDEE2222),
                        ),
                      ),
                    ),
                  )
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
