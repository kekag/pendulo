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
  // The numerator part of the time signature, denotes
  // the number of beats played per bar/measure.
  int numBeats = 4;
  // The 'denominator' part, indicating the type of note
  // being played; e.g. 4 for quarter note, 8 for eighth, etc.
  int beatDuration = 4;
  // Tempo of the time signature.
  double beatsPerMinute = 100.0;
  // Defines the number of meters, polyrhythm or polymeters
  // elements being concurrently displayed.
  int rhythmComponents = 1;

  void modifyMetronome(beats, duration, bpm) {
    setState(() {
      numBeats = beats;
      beatDuration = duration;
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
      body:
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('$numBeats, $beatDuration, $beatsPerMinute'),
            Center(
              child: Container(
                margin: EdgeInsets.all(35.0),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: rhythmComponents,
                itemBuilder: (context, index) {
                  return new GestureDetector(
                    onTap: () {
                      print("tapped");
                    },
                    child: new Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Container(
                        color: Colors.grey,
                        height: 100.0,
                      ),
                    ),
                  );
                },
              )
            )
          ],
        ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            bottom: 20,
            left: 30,
            child: FloatingActionButton(
              onPressed: () {},
              tooltip: 'Creates a polyrhythm',
              child: const Icon(
                Icons.add,
                size: 30,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3)
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            child: FloatingActionButton(
              onPressed: () {},
              tooltip: 'Creates a polyrhythm',
              child: const Icon(
                Icons.add,
                size: 30,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3)
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 30,
            child: FloatingActionButton(
              onPressed: () {},
              tooltip: 'Creates a polymeter',
              child: const Icon(
                Icons.add,
                size: 30,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3)
              ),
            ),
          ),
        ]
      ),
    );
  }
}
