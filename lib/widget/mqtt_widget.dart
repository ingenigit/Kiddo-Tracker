import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kiddo_tracker/mqtt/MQTTService.dart';
import 'package:kiddo_tracker/widget/mqtt_status_widget.dart';

class MqttWidget extends StatefulWidget {
  final Function(String) onMessageReceived;
  final Function(String) onStatusChanged;
  final Function(String) onLog;
  final Function(MQTTService) onInitialized;

  const MqttWidget({
    super.key,
    required this.onMessageReceived,
    required this.onStatusChanged,
    required this.onLog,
    required this.onInitialized,
  });

  @override
  State<MqttWidget> createState() => _MqttWidgetState();
}

class _MqttWidgetState extends State<MqttWidget> {
  late MQTTService _mqttService;
  String _mqttStatus = 'Disconnected';

  @override
  void initState() {
    super.initState();
    _initializeMQTT();
  }

  Future<void> _initializeMQTT() async {
    _mqttService = MQTTService(
      onMessageReceived: widget.onMessageReceived,
      onConnectionStatusChanged: _onMQTTStatusChanged,
      onLogMessage: widget.onLog,
    );
    await _mqttService.connect();
    widget.onInitialized(_mqttService);
  }

  void _onMQTTStatusChanged(String status) {
    setState(() {
      _mqttStatus = status;
    });
    widget.onStatusChanged(status);
  }

  @override
  Widget build(BuildContext context) {
    return MqttStatusWidget(mqttStatus: _mqttStatus);
  }
}
