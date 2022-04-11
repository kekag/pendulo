import 'package:flutter/material.dart';
import 'package:soundpool/soundpool.dart';
import 'package:pendulo/meter.dart';
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
  // Defines the maximum number of meters, polyrhythm or polymeters
  // elements being concurrently displayed.
  final maxComponents = 4;
  var components = <Widget>[
    MeterComponent(
      meter: MetronomeMeter(),
    ),
  ];

  addComponent(ComponentType t) {
    setState(() {
      if (components.length < maxComponents) {
        switch (t) {
          case ComponentType.meter:
            components.add(MeterComponent(
              meter: MetronomeMeter(),
            ));
            break;
          case ComponentType.polyrhythm:
            components.add(PolyrhythmComponent(
              meter: MetronomePolyrhythm(),
            ));
            break;
          case ComponentType.polymeter:
            components.add(PolymeterComponent(
              meter: MetronomePolymeter(),
            ));
            break;
          default:
            debugPrint('unknown component type: $t');
        }
      }
      debugPrint('components: $components');
    });
  }

  deleteComponent() {
    setState(() {});
  }

  Soundpool pool = Soundpool.fromOptions(
    options: const SoundpoolOptions(maxStreams: 1),
  );

  MetronomeState metronomeState = MetronomeState.stopped;
  int streamId = 0;

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
      body: Column(
        children: <Widget>[
          const Padding(padding: EdgeInsets.all(8)),
        ] + components,
        /*
         * children: <Widget>[
         *   const Padding(padding: EdgeInsets.all(5)),
         *   Expanded(
         *     child: ListView(
         *       // padding: const EdgeInsets.all(5),
         *       children: components,
         *     )
         *   )
         * ],
         */
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
                onPressed: () {
                  addComponent(ComponentType.meter);
                },
                tooltip: 'Adds a regular meter click-track to the metronome suite.',
                backgroundColor: const Color(0xcc555555),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Column(
                  children: const [
                    Padding(padding: EdgeInsets.all(1)),
                    Icon(Icons.add, size: 30, color: Colors.white),
                    Text('METER', style: TextStyle(color: Colors.white)),
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
                onPressed: () {
                  addComponent(ComponentType.polyrhythm);
                },
                tooltip: 'Adds a polyrhythm tool to the metronome suite.',
                backgroundColor: const Color(0xcc555555),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Column(
                  children: const [
                    Padding(padding: EdgeInsets.all(1)),
                    Icon(Icons.add, size: 30, color: Colors.white),
                    Text('POLYRHYTHM', style: TextStyle(color: Colors.white)),
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
                onPressed: () {
                  addComponent(ComponentType.polymeter);
                },
                tooltip: 'Adds a polymeter to the metronome suite.',
                backgroundColor: const Color(0xcc555555),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Column(
                  children: const [
                    Padding(padding: EdgeInsets.all(1)),
                    Icon(Icons.add, size: 30, color: Colors.white),
                    Text('POLYMETER', style: TextStyle(color: Colors.white)),
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
