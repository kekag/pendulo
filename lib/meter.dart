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

// Controls audio playback of the metronome, contains sample data
// and beat frequency.
class ClickTrack {
  MetronomeState metronomeState = MetronomeState.stopped;
  Meter meter = Meter();
  int beat = 1; // 1 <= x <= numBeats * subdivision
  Timer? beatTimer;
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

  ClickTrack() {
    _calcTickInterval(meter.beatsPerMinute);
    beatTimer = Timer.periodic(Duration(milliseconds: _tickInterval), _onBeat);
    _setupSoundIds();
  }

  ClickTrack.standard(this.meter, this.samples) {
    _calcTickInterval(meter.beatsPerMinute);
    beatTimer = Timer.periodic(Duration(milliseconds: _tickInterval), _onBeat);
    _setupSoundIds();
  }

  void updateMeter(Meter meter) {
    this.meter = meter;
    _calcTickInterval(meter.beatsPerMinute);
    beatTimer = Timer.periodic(Duration(milliseconds: _tickInterval), _onBeat);
  }

  void _calcTickInterval(int bpm) {
    double bps = bpm / 60;
    double subBps = bps * (meter.subdivision.index + 1);
    _tickInterval = 1000 ~/ subBps;
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
      case MetronomeState.starting:
      case MetronomeState.playing:
        if (beat == 1) {
          int _ = await _pool.play(_downbeatId);
        } else if (beat % (meter.subdivision.index + 1) != 0) {
          int _ = await _pool.play(_beatId);
        } else {
          int _ = await _pool.play(_subdivisionId);
        }

        if (beat == meter.numBeats * (meter.subdivision.index + 1)) {
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
  Subdivision subdivision = Subdivision.eighth;

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
  int beatDuration2 = 4;
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
