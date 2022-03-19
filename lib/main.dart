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
        primarySwatch: Colors.grey,
        textTheme: const TextTheme(bodyText2: TextStyle(
            fontWeight: FontWeight.w400
        ))
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
      decoration: const BoxDecoration(
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
          title: Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        body:
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // MetronomeMeter();
            Expanded(
              child: ListView.builder(
                itemCount: rhythmComponents,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Container(
                        color: const Color(0xBB666666),
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
                  child: Column(
                    children: const [
                      Padding(padding: EdgeInsets.all(3.0)),
                      Icon(
                        Icons.add,
                        size: 30,
                      ),
                      Text(
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
                  child: Column(
                    children: const [
                      Padding(padding: EdgeInsets.all(1.0)),
                      Icon(
                        Icons.add,
                        size: 30,
                      ),
                      Text(
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
                  child: Column(
                    children: const [
                      Padding(padding: EdgeInsets.all(1.0)),
                      Icon(
                        Icons.add,
                        size: 30,
                      ),
                      Text(
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
