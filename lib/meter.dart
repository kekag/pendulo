import 'dart:async';
import 'package:soundpool/soundpool.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

enum ComponentType {
  meter,
  polyrhythm,
  polymeter,
}

enum MetronomeState {
  starting,
  playing,
  stopping,
  stopped,
}

enum Subdivision {
  quarter,
  eighth,
  triplet,
  sixteenth,
}

// Base class for all shared subclass features.
class Metronome {
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

  MetronomeState metronomeState = MetronomeState.stopped;
  int beat = 1; // 1 <= x <= numBeats * subdivision
  Timer? beatTimer;
  Timer? visTimer;
  int _tickInterval = 16;
  final Soundpool _pool = Soundpool.fromOptions(
    options: const SoundpoolOptions(maxStreams: 3),
  );
  List<String> samples = [
    'assets/audio/Perc_Can_hi.wav',       // Downbeat
    'assets/audio/Perc_Can_lo.wav',       // Beat
    'assets/audio/Perc_Clackhead_lo.wav', // Subdivison
  ];
  int _downbeatId = 0;
  int _beatId = 0;
  int _subdivisionId = 0;
  Color barColor = const Color(0xCC222222);

  void updateMeter() {
    beatTimer?.cancel();
    visTimer?.cancel();
    _calcTickInterval();
    _calcTimers();
  }

  void _calcTickInterval() {
    double bps = beatsPerMinute / 60;
    double subBps = bps * (subdivision.index + 1);
    double ratio =  beatDuration / subdivisionDuration(subdivision);
    subBps *= ratio;
    _tickInterval = 1000 ~/ subBps;
  }

  void _calcTimers() {
    beatTimer = Timer.periodic(Duration(milliseconds: _tickInterval), _onBeat);
    visTimer = Timer.periodic(Duration(milliseconds: (_tickInterval + 3)), _clearBeat);
  }

  void _setupSoundIds() async {
    _downbeatId = await rootBundle.load(samples[0]).then((ByteData soundData) {
      return _pool.load(soundData);
    });
    _beatId = await rootBundle.load(samples[1]).then((ByteData soundData) {
      return _pool.load(soundData);
    });
    _subdivisionId = await rootBundle.load(samples[2]).then((ByteData soundData) {
      return _pool.load(soundData);
    });
  }

  void _onBeat(Timer t) async {
    switch (metronomeState) {
      case MetronomeState.playing:
        if (beat == 1) {
          int _ = await _pool.play(_downbeatId);
          barColor = Colors.greenAccent;
        } else if (beat % (subdivision.index + 1) != 1 &&
            subdivision != Subdivision.quarter) {
          int _ = await _pool.play(_subdivisionId);
          barColor = const Color(0xCCBBBBBB);
        } else {
          int _ = await _pool.play(_beatId);
          barColor = const Color(0xCCFFFFFF);
        }

        if (beat == numBeats * (subdivision.index + 1)) {
          beat = 1;
        } else {
          beat++;
        }
        break;
      case MetronomeState.stopping:
        beatTimer?.cancel();
        metronomeState = MetronomeState.stopped;
        beat = 1;
        break;
    }
  }

  void _clearBeat(Timer t) async {
    barColor = const Color(0xCC222222);
  }

  Metronome() {
    _calcTickInterval();
    _calcTimers();
    _setupSoundIds();
  }
}

// Standard meter, will not have many additional properties
// or functionality over superclass.
class MetronomeMeter extends Metronome {}

// Polyrhythm sequence which will have two agonist beats
// over the same subdivision.
class MetronomePolyrhythm extends Metronome {
  int numBeats2 = 3;
  Timer? beatTimer2;
  // int beat2 = 1;
  int _tickInterval2 = 12;

  @override
  void updateMeter() {
    beatTimer?.cancel();
    beatTimer2?.cancel();
    visTimer?.cancel();
    _calcTickInterval();
    _calcTimers();
  }

  @override
  void _calcTickInterval() {
    double bps = beatsPerMinute / 60;
    _tickInterval = 1000 ~/ bps;
    double ratio = numBeats / numBeats2;
    double bps2 = (beatsPerMinute * ratio) / 60;
    _tickInterval2 = 1000 ~/ bps2;
  }

  @override
  void _calcTimers() {
    beatTimer = Timer.periodic(Duration(milliseconds: _tickInterval), _onBeat);
    beatTimer2 = Timer.periodic(Duration(milliseconds: _tickInterval2), _onBeat);
    visTimer = Timer.periodic(Duration(milliseconds: (_tickInterval + 3)), _clearBeat);
  }

  @override
  void _onBeat(Timer t) async {
    switch (metronomeState) {
      case MetronomeState.playing:
        // if (beat == 1 && beat2 == 1) {
        //   int _ = await _pool.play(_downbeatId);
        //   numBeats > numBeats2 ? beat++ : beat2++;
        // }
        int _ = await _pool.play(_beatId);
        barColor = const Color(0xCCFFFFFF);
        break;
      case MetronomeState.stopping:
        beatTimer?.cancel();
        beatTimer2?.cancel();
        metronomeState = MetronomeState.stopped;
        break;
    }
  }
}

// Polymeter arrangement containing two meters with varying
// number of beats over the same duration.
class MetronomePolymeter extends Metronome {
  int numBeats2 = 4;
  int beatDuration2 = 4;
  int beat2 = 1;

  @override
  void _calcTickInterval() {
    double bps = beatsPerMinute / 60;
    _tickInterval = 1000 ~/ bps;
  }

  @override
  void _calcTimers() {
    beatTimer = Timer.periodic(Duration(milliseconds: _tickInterval), _onBeat);
    visTimer = Timer.periodic(Duration(milliseconds: (_tickInterval + 3)), _clearBeat);
  }

  @override
  void _onBeat(Timer t) async {
    switch (metronomeState) {
      case MetronomeState.playing:
        if (beat == 1 || beat2 == 1) {
          int _ = await _pool.play(_downbeatId);
          barColor = Colors.greenAccent;
        } else {
          int _ = await _pool.play(_beatId);
          barColor = const Color(0xCCFFFFFF);
        }

        if (beat == numBeats) {
          beat = 1;
        } else {
          beat++;
        }
        if (beat2 == numBeats2) {
          beat2 = 1;
        } else {
          beat2++;
        }
        break;
      case MetronomeState.stopping:
        beatTimer?.cancel();
        metronomeState = MetronomeState.stopped;
        break;
    }
  }
}

String convertSignature(int i) {
  if (i >= 100) {
    debugPrint('cannot handle signature of $i (>100)');
    return '';
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
      return '';
  }
}

int subdivisionDuration(Subdivision s) {
  switch (s) {
    case Subdivision.eighth:
      return 8;
    case Subdivision.sixteenth:
      return 16;
    default:
      return 4;
  }
}
