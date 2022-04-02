import 'package:flutter/material.dart';
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
        colorScheme: const ColorScheme.highContrastDark(),
        primarySwatch: Colors.green,
        textTheme: const TextTheme(
          button: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          )
        )
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
  int maxComponents = 4;

  addMetronomeComponent() {
    setState(() {
      if (rhythmComponents < maxComponents) {
        rhythmComponents++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          const Padding(padding: EdgeInsets.all(6)),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return MetronomeComponent(meter: MetronomeMeter());
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
            bottom: 7,
            left: 16,
            child: SizedBox(
              width: 108,
              height: 54,
              child: FloatingActionButton(
                onPressed: () {},
                tooltip: 'Adds a regular meter click-track to the metronome suite.',
                backgroundColor: const Color(0xcc555555),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2)
                ),
                child: Column(
                  children: const [
                    Padding(padding: EdgeInsets.all(1)),
                    Icon(Icons.add, size: 30, color: Colors.white),
                    Text("METER", style: TextStyle(color: Colors.white),),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 7,
            child: SizedBox(
              width: 108,
              height: 54,
              child: FloatingActionButton(
                onPressed: () {},
                tooltip: 'Adds a polyrhythm tool to the metronome suite.',
                backgroundColor: const Color(0xcc555555),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2)
                ),
                child: Column(
                  children: const [
                    Padding(padding: EdgeInsets.all(1)),
                    Icon(Icons.add, size: 30, color: Colors.white),
                    Text("POLYRHYTHM", style: TextStyle(color: Colors.white),),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 7,
            right: 16,
            child: SizedBox(
              width: 108,
              height: 54,
              child: FloatingActionButton(
                onPressed: () {},
                tooltip: 'Adds a polymeter to the metronome suite.',
                backgroundColor: const Color(0xcc555555),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Column(
                  children: const [
                    Padding(padding: EdgeInsets.all(1)),
                    Icon(Icons.add, size: 30, color: Colors.white),
                    Text("POLYMETER", style: TextStyle(color: Colors.white),),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
