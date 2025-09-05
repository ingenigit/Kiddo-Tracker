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
import 'package:kiddo_tracker/widget/child_card_widget.dart';
import 'package:kiddo_tracker/widget/mqtt_status_widget.dart';
import 'package:kiddo_tracker/widget/shareperference.dart';
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

  // Map to track active status of routes by routeId_oprid key
  Map<String, bool> activeRoutes = {};

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
                  MqttStatusWidget(mqttStatus: _mqttStatus),
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
                              return ChildCardWidget(
                                    child: child,
                                    subscription:
                                        studentSubscriptions[child.studentId],
                                    onSubscribeTap: () => _onSubscribe(child),
                                    onOnboardTap: (routeId, routes) =>
                                        _onOnboard(
                                          routeId,
                                          routes.cast<RouteInfo>(),
                                        ),
                                    onOffboardTap: (routeId, routes) =>
                                        _onOffboard(
                                          routeId,
                                          routes.cast<RouteInfo>(),
                                        ),
                                    onAddRouteTap: () => _onAddRoute(child),
                                    activeRoutes: activeRoutes,
                                  )
                                  .animate()
                                  .fade(duration: 600.ms)
                                  .slide(begin: const Offset(0, 0.1));
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
        List<RouteInfo> allParsedRouteInfo = [];
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
          //store routeInfo data
          allParsedRouteInfo.addAll(parsedRouteInfo);
          Logger().i("${child.toJson()} $parsedRouteInfo");
        }

        // Subscribe to topics based on student_ids
        List<String> topics = children.map((child) => child.studentId).toList();
        // Subscribe to topics based on routeInfo's routeId + oprid
        topics.addAll(
          allParsedRouteInfo
              .map((route) => '${route.routeId}/${route.oprid}')
              .toList(),
        );
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
    try {
      // Parse the MQTT message JSON
      final Map<String, dynamic> jsonMessage = jsonDecode(message);

      final Map<String, dynamic> data =
          jsonMessage['data'] as Map<String, dynamic>;
      final int? msgtype = data['msgtype'] as int?;

      if (msgtype == 2) {
        // Onboard message
        final String? studentId = data['studentid'] as String?;
        final int status = data['status'] as int? ?? 1; // Default to onboard

        if (studentId != null) {
          _updateChildStatus(studentId, status);
        } else {
          Logger().w('Missing studentid in onboard message');
        }
      } else if (msgtype == 3) {
        // Offboard message
        final List<dynamic>? offlist = data['offlist'] as List<dynamic>?;

        if (offlist != null) {
          for (var id in offlist) {
            if (id is String) {
              _updateChildStatus(id, 2); // Offboard status
            }
          }
        } else {
          Logger().w('Missing offlist in offboard message');
        }
      } else if (msgtype == 1 || msgtype == 4) {
        String devid = jsonMessage['devid'] ?? '';
        if (devid.isNotEmpty) {
          setState(() {
            for (var child in children) {
              for (var route in child.routeInfo) {
                String key = '${route.routeId}_${route.oprid}';
                if (key == devid) {
                  //also push notification
                  NotificationService.showNotification(
                    id: 0,
                    title: 'KT Status Update',
                    body:
                        'Bus ${route.routeName} has been ${msgtype == 1 ? 'activated' : 'deactivated'}.',
                  );
                  if (msgtype == 1) {
                    activeRoutes[key] = true;
                  } else if (msgtype == 4) {
                    activeRoutes[key] = false;
                  }
                }
              }
            }
          });
        } else {
          Logger().w('Missing devid in bus active/inactive message');
        }
      } else {
        Logger().w('Unknown msgtype: $msgtype');
      }
    } catch (e) {
      Logger().e('Error parsing MQTT message: $e');
    }
  }

  void _updateChildStatus(String studentId, int status) {
    final childIndex = children.indexWhere(
      (child) => child.studentId == studentId,
    );
    if (childIndex != -1) {
      // Show a notification
      NotificationService.showNotification(
        id: 0,
        title: 'KT Status Update',
        body:
            'Child ${children[childIndex].name} has been ${status == 1 ? 'onboarded' : 'offboarded'}.',
      );

      // Update the status of the child
      Logger().i('Updating status for child $studentId to $status');
      setState(() {
        children[childIndex] = Child(
          studentId: children[childIndex].studentId,
          name: children[childIndex].name,
          nickname: children[childIndex].nickname,
          school: children[childIndex].school,
          class_name: children[childIndex].class_name,
          rollno: children[childIndex].rollno,
          age: children[childIndex].age,
          gender: children[childIndex].gender,
          tagId: children[childIndex].tagId,
          routeInfo: children[childIndex].routeInfo,
          status: children[childIndex].status,
          onboard_status: status, //children[childIndex].onboard_status,
        );
      });
      Logger().i('Updated status for child $studentId to $status');
    } else {
      Logger().w('Child with studentId $studentId not found');
    }
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

  // Action methods
  void _onSubscribe(Child child) {
    // Implement subscribe action
    Logger().i('Subscribe clicked for ${child.name}');
    // Add your subscription logic here
  }

  void _onOnboard(String routeId, List<RouteInfo> routes) {
    // Implement onboard action
    Logger().i('Onboard clicked for route $routeId');
    // Add your onboard logic here
  }

  void _onOffboard(String routeId, List<RouteInfo> routes) {
    // Implement offboard action
    Logger().i('Offboard clicked for route $routeId');
    // Add your offboard logic here
  }

  void _onAddRoute(Child child) {
    // Implement add route action
    Logger().i('Add route clicked for ${child.name}');
    // Add your add route logic here
  }
}
