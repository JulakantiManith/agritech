import 'dart:async';
import 'package:flutter/material.dart';

class SensorsPage extends StatefulWidget {
  const SensorsPage({super.key});

  @override
  State<SensorsPage> createState() => _SensorsPageState();
}

class _SensorsPageState extends State<SensorsPage> {
  double temperature = 28.0;
  double humidity = 60.0;
  double soilMoisture = 45.0;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startMockUpdates();
  }

  void _startMockUpdates() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        temperature = 25 + (5 * (timer.tick % 3));
        humidity = 55 + (10 * (timer.tick % 2));
        soilMoisture = 40 + (8 * (timer.tick % 3));
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget sensorCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Field Sensors"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            sensorCard(
              title: "Temperature",
              value: "${temperature.toStringAsFixed(1)} °C",
              icon: Icons.thermostat,
              color: Colors.red,
            ),
            sensorCard(
              title: "Humidity",
              value: "${humidity.toStringAsFixed(1)} %",
              icon: Icons.water_drop,
              color: Colors.blue,
            ),
            sensorCard(
              title: "Soil Moisture",
              value: "${soilMoisture.toStringAsFixed(1)} %",
              icon: Icons.grass,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
