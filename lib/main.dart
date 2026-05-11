import 'package:flutter/material.dart';
import 'services/speech_service.dart';
import 'services/meter_processor.dart';
import 'services/ble_service.dart';
import 'services/dmmdecoder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final speech = SpeechService();

  await speech.init();

  runApp(MainApp(speech: speech));
}

class MainApp extends StatelessWidget {
  final SpeechService speech;

  const MainApp({super.key, required this.speech});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: HomePage(speech: speech),
    );
  }
}

class HomePage extends StatefulWidget {
  final SpeechService speech;

  const HomePage({super.key, required this.speech});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late MeterProcessor processor;
  late BLEService ble;
  String currentValue = "";
  String currentMode = "";
  String status = "Disconnected";

  @override
  void initState() {
    super.initState();
    processor = MeterProcessor(widget.speech);
    ble = BLEService();
    startBLE();
  }

  Future<void> startBLE() async {
    setState(() {
      status = "Scanning...";
    });

    await ble.startScan(
      onData: (data) async {
        setState(() {
          status = "Connected";
        });

        final d = decode(data);

        final state = processor.decodeMeterState(
          d["display"],
          Set<String>.from(d["icons"]),
        );

        await processor.processState(state);

        setState(() {
          currentValue = "${state.value} ${state.unit}";

          currentMode = processor.modeNames[state.family] ?? "";
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("VoxDMM")),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Text(currentValue, style: const TextStyle(fontSize: 40)),

            const SizedBox(height: 20),

            Text(currentMode, style: const TextStyle(fontSize: 24)),

            const SizedBox(height: 40),
            Text(status, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
