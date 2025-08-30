import 'package:flutter/material.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  // This list will hold all notifications received from MQTT
  List<String> notifications = [];

  // Simulate receiving notifications from MQTT
  // Replace this with your actual MQTT subscription logic
  void _simulateMqttNotification(String message) {
    setState(() {
      notifications.insert(0, message);
    });
  }

  @override
  void initState() {
    super.initState();
    // Example: Simulate receiving notifications
    Future.delayed(const Duration(seconds: 2), () {
      _simulateMqttNotification("Welcome! MQTT connected.");
    });
    Future.delayed(const Duration(seconds: 4), () {
      _simulateMqttNotification("New activity detected.");
    });
    // TODO: Replace above with actual MQTT subscription and message handling
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Notifications'),
      ),
      body: notifications.isEmpty
          ? const Center(child: Text('No notifications received yet.'))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text(notifications[index]),
                );
              },
            ),
    );
  }
}