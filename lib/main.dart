import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:pendulo/metronome.dart';

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
  // Defines the number of meters, polyrhythm or polymeters
  // elements being concurrently displayed.
  int rhythmComponents = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          radius: 0.2,
          colors: <Color>[
            Color(0x151515FF),
            Color(0x0F0F0FFF),
          ],
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.title),
        ),
        body:
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // MetronomeMeter(),
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
            alignment: Alignment.center,
            children: [
              Positioned(
                bottom: 6,
                left: 18,
                child: FloatingActionButton(
                  onPressed: () {},
                  tooltip: 'Adds a regular meter click-track to the metronome suite.',
                  child: new Column(
                    children: [
                      const Padding(padding: EdgeInsets.all(3.0)),
                      const Icon(
                        Icons.add,
                        size: 30,
                      ),
                      const Text(
                        "meter",
                        style: TextStyle(
                          fontSize: 10.0,
                        ),
                      ),
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3)
                  ),
                ),
              ),
              Positioned(
                bottom: 6,
                child: FloatingActionButton(
                  onPressed: () {},
                  tooltip: 'Adds a polyrhythm tool to the metronome suite.',
                  child: new Column(
                    children: [
                      const Padding(padding: EdgeInsets.all(1.0)),
                      const Icon(
                        Icons.add,
                        size: 30,
                      ),
                      const Text(
                        "poly\nrhythm",
                        style: TextStyle(
                          fontSize: 10.0,
                          height: 0.9,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3)
                  ),
                ),
              ),
              Positioned(
                bottom: 6,
                right: 18,
                child: FloatingActionButton(
                  onPressed: () {},
                  tooltip: 'Adds a polymeter to the metronome suite.',
                  child: new Column(
                    children: [
                      const Padding(padding: EdgeInsets.all(1.0)),
                      const Icon(
                        Icons.add,
                        size: 30,
                      ),
                      const Text(
                        "poly\nmeter",
                        style: TextStyle(
                          fontSize: 10.0,
                          height: 0.9,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3)
                  ),
                ),
              ),
            ]
          ),
        ),
    );
  }
}
