import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp ({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Servo Controller', home: ServoControlScreen());
  }
}

class ServoControlScreen extends StatefulWidget {
  const ServoControlScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ServoControlScreenState createState() => _ServoControlScreenState();
}

class _ServoControlScreenState extends State<ServoControlScreen> {
  final _channel = WebSocketChannel.connect(
    Uri.parse('ws://192.168.4.1:81'), // Replace with your ESP32 IP
  );

  double servo1 = 90;
  double servo2 = 90;

  void _sendValues() {
    final message = "Servo1: $servo1, Servo2: $servo2";
    _channel.sink.add(message);
  }

  void _resetServo(int id) {
    setState(() {
      if (id == 1) servo1 = 90;
      if (id == 2) servo2 = 90;
      _sendValues();
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Center(child: Text ('Mini-Car Control Flutter UI')),
        backgroundColor: Color.fromARGB(223, 158, 223, 255),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSlider(
              title: "Servo1",
              value: servo1,
              onChanged:
                  (val) => setState(() {
                    servo1 = val;
                    _sendValues();
                  }),
              onEnd: () => _resetServo(1),
              isVertical: false,
            ),
            _buildSlider(
              title: "Servo2",
              value: servo2,
              onChanged:
                  (val) => setState(() {
                    servo2 = val;
                    _sendValues();
                  }),
              onEnd: () => _resetServo(2),
              isVertical: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String title,
    required double value,
    required void Function(double) onChanged,
    required void Function() onEnd,
    bool isVertical = false,
  }) {
    final slider = SliderTheme(
      data: SliderThemeData(
        activeTrackColor: Color(0xFFFFD65C),
        thumbColor: Color(0xFF034078),
        trackHeight: 15,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 15),
      ),
      child: Slider(
        value: value,
        min: 0,
        max: 180,
        onChanged: onChanged,
        onChangeEnd: (_) => onEnd(),
      ),
    );

    return Container(
      width: 160,
      height: 300,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title),
          SizedBox(height: 10),
          isVertical ? RotatedBox(quarterTurns: 3, child: slider) : slider,
          Text(
            "${value.toInt()}°",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
