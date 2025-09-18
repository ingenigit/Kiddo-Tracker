import 'package:flutter/material.dart';

class MqttStatusWidget extends StatelessWidget {
  final String mqttStatus;

  const MqttStatusWidget({super.key, required this.mqttStatus});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: mqttStatus == 'Connected'
          ? Colors.green.shade100
          : Colors.red.shade100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            mqttStatus == 'Connected' ? Icons.wifi : Icons.wifi_off,
            size: 16,
            color: mqttStatus == 'Connected' ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            'MQTT: $mqttStatus',
            style: TextStyle(
              fontSize: 12,
              color: mqttStatus == 'Connected'
                  ? Colors.green.shade800
                  : Colors.red.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
