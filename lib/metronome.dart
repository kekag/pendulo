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
