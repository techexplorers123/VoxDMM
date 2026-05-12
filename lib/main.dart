import 'dart:async';
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
      theme: ThemeData(
        visualDensity: VisualDensity.compact,
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white24,
          onBackground: Colors.white10,
          onSurface: Colors.white10,
        ),
      ),
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
  StreamSubscription? bleSub;
  StreamSubscription? statusSub;
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
    String? lastStatus;
    statusSub = ble.statusStream.listen((newStatus) async {
      if (!mounted) return;
      setState(() {
        status = newStatus;
      });
      if (newStatus == lastStatus) {
        return;
      }
      lastStatus = newStatus;
      await widget.speech.speak(newStatus, interrupt: true);
    });
    bleSub = ble.dataStream.listen((data) async {
      final decoded = decode(data);

      final state = processor.decodeMeterState(decoded.display, decoded.icons);

      await processor.processState(state);

      if (!mounted) return;

      setState(() {
        currentValue = "${state.value} ${state.unit}";
        currentMode = processor.modeNames[state.family] ?? "";
      });
    });

    try {
      await ble.start();
    } catch (e) {
      setState(() {
        status = e.toString();
      });
    }
  }

  @override
  void dispose() {
    bleSub?.cancel();
    statusSub?.cancel();
    unawaited(ble.dispose());
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("VoxDMM")),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                currentValue,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 40),
              ),

              const SizedBox(height: 20),

              Text(
                currentMode,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24),
              ),

              const SizedBox(height: 40),

              Text(
                status,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
