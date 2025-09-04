import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kiddo_tracker/api/apimanage.dart';
import 'package:kiddo_tracker/model/child.dart';
import 'package:kiddo_tracker/model/parent.dart';
import 'package:kiddo_tracker/model/route.dart';
import 'package:kiddo_tracker/model/subscribe.dart';
import 'package:kiddo_tracker/mqtt/MQTTService.dart';
import 'package:kiddo_tracker/services/notification_service.dart';
import 'package:kiddo_tracker/widget/shareperference.dart';
import 'package:kiddo_tracker/widget/sqflitehelper.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<Child> children = [];
  List<SubscriptionPlan> subscriptionPlans = [];
  Map<String, SubscriptionPlan> studentSubscriptions = {};
  bool _isLoading = true;

  late final AnimationController _controller;
  late final Animation<double> _animation;

  late MQTTService _mqttService;
  String _mqttStatus = 'Disconnected';

  @override
  void initState() {
    super.initState();
    _fetchChildren();
    _initializeMQTT();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _statusText(int status) {
    switch (status) {
      case 1:
        return 'Onboard';
      case 2:
        return 'Offboard';
      default:
        return 'Offboard';
    }
  }

  Map<String, List<RouteInfo>> _groupRoutesByRouteId(List<RouteInfo> routes) {
    Map<String, List<RouteInfo>> grouped = {};
    for (var route in routes) {
      if (!grouped.containsKey(route.routeId)) {
        grouped[route.routeId] = [];
      }
      grouped[route.routeId]!.add(route);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _animation,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // MQTT Status Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: _mqttStatus == 'Connected'
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _mqttStatus == 'Connected'
                              ? Icons.wifi
                              : Icons.wifi_off,
                          size: 16,
                          color: _mqttStatus == 'Connected'
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'MQTT: $_mqttStatus',
                          style: TextStyle(
                            fontSize: 12,
                            color: _mqttStatus == 'Connected'
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: children.isEmpty
                        ? const Center(
                            child: Text(
                              'No children found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: children.length,
                            itemBuilder: (context, index) {
                              final child = children[index];
                              final groupedRoutes = _groupRoutesByRouteId(
                                child.routeInfo,
                              );

                              return Card(
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Top row: Name, status, location icon
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            child.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Builder(
                                                builder: (context) {
                                                  var sub =
                                                      studentSubscriptions[child
                                                          .studentId];
                                                  Logger().i(sub);
                                                  //if sub is null make it subscribe else show status
                                                  if (sub == null) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        print(
                                                          'Subscribe clicked for ${child.name}',
                                                        );
                                                      },
                                                      child: Text(
                                                        "Subscribe",
                                                        style: const TextStyle(
                                                          color: Colors.blue,
                                                          fontSize: 14,
                                                          fontFamily: 'Poppins',
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    //check if sub is expired
                                                    bool isExpired =
                                                        DateTime.parse(
                                                          sub.enddate,
                                                        ).isBefore(
                                                          DateTime.now(),
                                                        );
                                                    if (isExpired) {
                                                      return GestureDetector(
                                                        onTap: () {
                                                          print(
                                                            'Subscribe clicked for ${child.name}',
                                                          );
                                                        },
                                                        child: Text(
                                                          "Subscribe",
                                                          style: const TextStyle(
                                                            color: Colors.blue,
                                                            fontSize: 14,
                                                            fontFamily:
                                                                'Poppins',
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      return Text(
                                                        _statusText(
                                                          child.status,
                                                        ),
                                                        style: const TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 14,
                                                          fontFamily: 'Poppins',
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                              ),
                                              const SizedBox(width: 4),
                                              const Icon(
                                                Icons.location_on_outlined,
                                                size: 18,
                                                color: Colors.grey,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      // Unit info
                                      Text(
                                        child.school,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Route cards
                                      Column(
                                        children: groupedRoutes.entries.map((
                                          entry,
                                        ) {
                                          final routeId = entry.key;
                                          final routes = entry.value;

                                          // Find earliest stopArrivalTime for route start time
                                          String startTime = '';
                                          if (routes.isNotEmpty) {
                                            routes.sort(
                                              (a, b) => a.stopArrivalTime
                                                  .compareTo(b.stopArrivalTime),
                                            );
                                            startTime =
                                                routes.first.stopArrivalTime;
                                          }

                                          // Find onboard and offboard stops (assuming stopName contains 'Onboard' or 'Offboard')
                                          String onboardTime = '_';
                                          String offboardTime = '_';
                                          for (var r in routes) {
                                            if (r.stopName
                                                .toLowerCase()
                                                .contains('onboard')) {
                                              onboardTime = r.stopArrivalTime;
                                            } else if (r.stopName
                                                .toLowerCase()
                                                .contains('offboard')) {
                                              offboardTime = r.stopArrivalTime;
                                            }
                                          }

                                          return Card(
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 6,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                12.0,
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          '${routes.first.routeName} starts at $startTime',
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontFamily:
                                                                    'Poppins',
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 6,
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            // TODO: Implement onboard time action
                                                          },
                                                          child: Text(
                                                            'Onboard at $onboardTime',
                                                            style: const TextStyle(
                                                              color:
                                                                  Colors.blue,
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline,
                                                              fontFamily:
                                                                  'Poppins',
                                                            ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            // TODO: Implement offboard time action
                                                          },
                                                          child: Text(
                                                            'Offboard at $offboardTime',
                                                            style: const TextStyle(
                                                              color:
                                                                  Colors.blue,
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline,
                                                              fontFamily:
                                                                  'Poppins',
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Icon(
                                                    Icons
                                                        .directions_bus_outlined,
                                                    size: 30,
                                                    color: Colors.grey,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      const SizedBox(height: 8),
                                      // Add Route button
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // TODO: Implement add route action
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.lightBlue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text(
                                            'Add Route',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ).animate().fade(duration: 600.ms).slide(begin: const Offset(0, 0.1));
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _fetchChildren() async {
    try {
      //get from shared preferences
      final String? userId = await SharedPreferenceHelper.getUserNumber();

      final response = await ApiManager().post(
        'ktrackuserbymobile',
        data: {'passkey': "Usr.KdTrac4\$Dat", 'mobile': userId},
      );
      final data = response.data;
      Logger().i(data);
      if (data[0]['result'] == 'ok') {
        final List userInfo = List.from(
          data[1]['userdata'] as List<dynamic>? ?? [],
        );
        final List studentInfo = List.from(
          data[2]['studentdata'] as List<dynamic>? ?? [],
        );
        Parent parent = Parent(
          userid: userInfo[0]['userid'],
          name: userInfo[0]['name'],
          city: userInfo[0]['city'],
          state: userInfo[0]['state'],
          address: userInfo[0]['address'],
          contact: userInfo[0]['contact'],
          email: userInfo[0]['email'],
          mobile: userInfo[0]['mobile'],
          wards: userInfo[0]['wards'],
          status: userInfo[0]['status'],
          sessionid: userInfo[0]['sessionid'],
        );
        Logger().i(parent.toJson().toString());

        // Fetch subscription data
        await _fetchAndSetSubscriptionPlans(
          userInfo[0]['userid'],
          studentInfo,
          userInfo[0]['sessionid'],
        );

        //////////////////////////////////////////////////////////////
        for (var student in studentInfo) {
          Logger().i(student.toString());
          List<RouteInfo> parsedRouteInfo = [];
          if (student['route_info'] != null) {
            if (student['route_info'] is String &&
                (student['route_info'] as String).isNotEmpty) {
              try {
                var decoded = jsonDecode(student['route_info']);
                if (decoded is List) {
                  parsedRouteInfo = decoded
                      .map<RouteInfo>(
                        (e) => RouteInfo.fromJson(
                          e is String
                              ? jsonDecode(e)
                              : e as Map<String, dynamic>,
                        ),
                      )
                      .toList();
                }
              } catch (e) {
                Logger().e("Error parsing route_info: $e");
              }
            } else if (student['route_info'] is List) {
              parsedRouteInfo = (student['route_info'] as List)
                  .map<RouteInfo>(
                    (e) => RouteInfo.fromJson(
                      e is String ? jsonDecode(e) : e as Map<String, dynamic>,
                    ),
                  )
                  .toList();
            }
          }
          Child child = Child(
            studentId: student['student_id'],
            name: student['name'],
            nickname: student['nickname'],
            school: student['school'],
            class_name: student['class'],
            rollno: student['rollno'],
            age: student['age'],
            gender: student['gender'],
            tagId: student['tag_id'],
            routeInfo: parsedRouteInfo,
            status: student['status'],
            onboard_status: student['onboard_status'],
          );
          //store children data
          children.add(child);
          Logger().i(child.toJson().toString());
        }

        // Subscribe to topics based on student_ids
        List<String> topics = children.map((child) => child.studentId).toList();
        _mqttService.subscribeToTopics(topics);
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching children: $e');
    }
  }

  Future<void> _fetchAndSetSubscriptionPlans(
    String userId,
    List studentInfo,
    String sessionid,
  ) async {
    try {
      final response = await ApiManager().post(
        'ktusersubplansbyuid',
        data: {'userid': userId, 'sessionid': sessionid},
      );
      final data = response.data;
      Logger().i(data);
      if (data[0]['result'] == 'ok') {
        final List subscriptionData = List.from(
          data[1]['data'] as List<dynamic>? ?? [],
        );
        for (var subscription in subscriptionData) {
          SubscriptionPlan subscriptionPlan = SubscriptionPlan(
            student_id: subscription['student_id'],
            plan_name: subscription['plan_name'],
            plan_details: subscription['plan_details'],
            validity: subscription['validity'],
            price: subscription['price'],
            startdate: subscription['startdate'],
            enddate: subscription['enddate'],
            status: subscription['status'],
            userid: subscription['userid'],
          );
          //store subscription data
          subscriptionPlans.add(subscriptionPlan);
          // store subscription plan data
          studentSubscriptions[subscriptionPlan.student_id] = subscriptionPlan;
          Logger().i(subscriptionPlan.toJson().toString());
        }
      }
    } catch (e) {
      print('Error fetching subscription plans: $e');
    }
  }

  void _initializeMQTT() {
    _requestNotificationPermission();
    _mqttService = MQTTService(
      onMessageReceived: _onMQTTMessageReceived,
      onConnectionStatusChanged: _onMQTTStatusChanged,
      onLogMessage: _onMQTTLog,
    );
    _mqttService.connect();
  }

  void _onMQTTMessageReceived(String message) {
    //push local notification
    NotificationService.showNotification(
      id: 0,
      title: 'MQTT Message',
      body: message,
    );
  }

  void _onMQTTStatusChanged(String status) {
    setState(() {
      _mqttStatus = status;
    });
  }

  void _onMQTTLog(String log) {
    Logger().i('MQTT: $log');
  }

  void _requestNotificationPermission() async {
    if (await Permission.notification.isGranted) {
      // Permission already granted
      return;
    }

    // Request notification permission
    final status = await Permission.notification.request();

    if (status.isGranted) {
      // Permission granted
    } else if (status.isDenied) {
      // Permission denied
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied
    }
  }
}
