import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Computer Modern',
        colorScheme: const ColorScheme.dark(),
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'PENDULO'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int numBeats = 4;
  int beatDuration = 4;
  double beatsPerMinute = 100.0;

  /* void changeTimeSignature(beats, duration) {
    setState(() {
      numBeats = beats;
      beatDuration = duration;
    });
  } */

  void changeTimeSignature() {
    setState(() {
      numBeats++;
      beatDuration++;
    });
  }

  void changeBPM(bpm) {
    setState(() {
      beatsPerMinute = bpm;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(35.0),
          decoration: BoxDecoration(
            color: Colors.white10,
            shape: BoxShape.circle,
          ),
        ),
        /*Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('$numBeats, $beatDuration, $beatsPerMinute'),
            /* RangeSlider(
              values: RangeValues(4, 8),
              onChanged: (newBeats) {
                setState(() {
                  numBeats = newBeats;
                });
              },
              min: 1,
              max: 31,
            ),
            RangeSlider(
              values: RangeValues(2, 16),
              onChanged: (newBeats) {
                setState(() {
                  numBeats = newBeats;
                });
              },
              min: 2,
              max: 16,
            ), */
          ],
        ),*/
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: changeTimeSignature,
        tooltip: 'Creates another meter',
        child: const Icon(Icons.add),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      )
      /*polyrhythmButton: FloatingActionButton(
        onPressed: changeTimeSignature,
        tooltip: 'Creates a polyrhythm',
        child: const Icon(Icons.add),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      ),
      polymeterButton: FloatingActionButton(
        onPressed: changeTimeSignature,
        tooltip: 'Creates a polymeter',
        child: const Icon(Icons.add),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      )*/
    );
  }
}
