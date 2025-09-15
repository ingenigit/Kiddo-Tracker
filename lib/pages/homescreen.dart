import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kiddo_tracker/api/apimanage.dart';
import 'package:kiddo_tracker/model/child.dart';
import 'package:kiddo_tracker/model/parent.dart';
import 'package:kiddo_tracker/model/route.dart';
import 'package:kiddo_tracker/model/subscribe.dart';
import 'package:kiddo_tracker/mqtt/MQTTService.dart';
import 'package:kiddo_tracker/routes/routes.dart';
import 'package:kiddo_tracker/services/global_event.dart';
import 'package:kiddo_tracker/services/notification_service.dart';
import 'package:kiddo_tracker/widget/child_card_widget.dart';
import 'package:kiddo_tracker/widget/location_and_route_dialog.dart';
import 'package:kiddo_tracker/widget/mqtt_status_widget.dart';
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
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  List<Child> children = [];
  List<SubscriptionPlan> subscriptionPlans = [];
  Map<String, SubscriptionPlan> studentSubscriptions = {};
  bool _isLoading = true;
  final SqfliteHelper _sqfliteHelper = SqfliteHelper();

  bool _hasInitialized = false;

  late final AnimationController _controller;
  late final Animation<double> _animation;

  late MQTTService _mqttService;
  String _mqttStatus = 'Disconnected';

  Map<String, bool> activeRoutes = {};
  int _boardRefreshKey = 0;
  late StreamSubscription<String> _streamSubscription;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (!_hasInitialized) {
      _initializeMQTT();
      _fetchChildren();
      _hasInitialized = true;
    }

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    _streamSubscription = GlobalEvent().eventStream.listen((event) {
      if (event == 'childDeleted') {
        setState(() {
          _isLoading = true;
        });
        _fetchChildren();
      }
    });
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
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
                                    onBusTap: (routeId, routes) =>
                                        _onBusTap(routeId, routes),
                                    onLocationTap: (routeId, routes) =>
                                        _onLocationTap(routeId, routes),
                                    onDeleteTap: (routeId, routes) =>
                                        _onDeleteTap(
                                          routeId,
                                          routes,
                                          child.studentId,
                                        ),
                                    onAddRouteTap: () => _onAddRoute(child),
                                    activeRoutes: activeRoutes,
                                    boardRefreshKey: _boardRefreshKey,
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
    Logger().i('Fetching children...');
    try {
      // Clear old data
      children.clear();
      subscriptionPlans.clear();
      studentSubscriptions.clear();
      activeRoutes.clear();
      // Unsubscribe from old MQTT topics if any
      _mqttService.unsubscribeFromAllTopics();

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
        // Clear previous data before inserting new data
        _sqfliteHelper.clearAllData();
        //store userInfo to sqflite
        await _sqfliteHelper.insertUser(parent);
        //store session data
        SharedPreferenceHelper.setUserSessionId(userInfo[0]['sessionid']);
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
          //store child data to sqflite
          await _sqfliteHelper.insertChild(child);
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
          _updateChildStatus(studentId, status, jsonMessage);
        } else {
          Logger().w('Missing studentid in onboard message');
        }
      } else if (msgtype == 3) {
        // Offboard message
        final List<dynamic>? offlist = data['offlist'] as List<dynamic>?;

        if (offlist != null) {
          for (var id in offlist) {
            if (id is String) {
              _updateChildStatus(id, 2, jsonMessage); // Offboard status
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

  void _updateChildStatus(
    String studentId,
    int status,
    Map<String, dynamic> jsonMessage,
  ) {
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
      //save to database
      _sqfliteHelper.insertActivity({
        'student_id': studentId,
        'student_name': children[childIndex].name,
        'status': status == 1 ? 'onboarded' : 'offboarded',
        'location': jsonMessage['data']['location'],
        'route_id': jsonMessage['devid'].split('_')[0],
        'oprid': jsonMessage['devid'].split('_')[1],
      });

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
        if (status == 1 || status == 2) {
          _boardRefreshKey++;
        }
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
  void _onSubscribe(Child child) async {
    // Implement subscribe action
    Logger().i('Subscribe clicked for ${child.name}, ${child.studentId}');
    // Add your subscription logic here
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.subscribe,
      arguments: child.studentId,
    );
    if (result == true) {
      _fetchChildren();
    }
  }

  void _onOnboard(String routeId, List<RouteInfo> routes) {
    // Implement onboard action
    Logger().i('Onboard clicked for route $routeId');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Onboard tapped for route $routeId')),
    );
    // Add your onboard logic here
  }

  void _onOffboard(String routeId, List<RouteInfo> routes) {
    // Implement offboard action
    Logger().i('Offboard clicked for route $routeId');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Offboard tapped for route $routeId')),
    );
    // Add your offboard logic here
  }

  void _onAddRoute(Child child) async {
    Logger().i('Add route clicked for ${child.name}');
    // Navigate to AddChildRoutePage and wait for result
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.addRoute,
      arguments: {'childName': child.nickname, 'childId': child.studentId},
    );

    // If a new route was added successfully, refresh the children list to show updated data
    if (result == true) {
      setState(() {
        _isLoading = true;
      });
      await _fetchChildren();
    }
  }

  _onBusTap(String routeId, List<RouteInfo> routes) {
    // Implement bus tap action
    Logger().i('Bus tapped for route $routeId');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Bus tapped for route $routeId')));
    // Add your bus tap logic here
  }

  _onLocationTap(String routeId, List<RouteInfo> routes) async {
    final userId = await SharedPreferenceHelper.getUserNumber();
    final sessionId = await SharedPreferenceHelper.getUserSessionId();
    final oprId = routes.first.oprid;
    final vehicleId = routes.first.vehicleId;
    Logger().i(
      'Location tapped for route $routeId, userId: $userId, oprId: $oprId, sessionId: $sessionId',
    );

    try {
      final responseRouteDetail = await ApiManager().post(
        'ktuvehicleinfo/',
        data: {
          'userid': userId,
          'sessionid': sessionId,
          'vehicle_id': vehicleId,
        },
      );

      final responseLocation = await ApiManager().post(
        'ktuoperationstatus/',
        data: {'userid': userId, 'oprid': oprId, 'sessionid': sessionId},
      );

      final map = _extractLocationAndRouteData(
        responseLocation,
        responseRouteDetail,
      );
      Logger().i(map);
      //now open a custom dialog to show location and route details
      _showLocationAndRouteDialog(map);
    } catch (e) {
      Logger().e('Error fetching location and route details: $e');
    }
  }

  Map<String, dynamic> _extractLocationAndRouteData(
    dynamic responseLocation,
    dynamic responseRouteDetail,
  ) {
    final Map<String, dynamic> map = {};

    if (responseLocation.statusCode == 200 &&
        responseRouteDetail.statusCode == 200) {
      Logger().i(responseLocation.data);
      if (responseLocation.data.isNotEmpty &&
          responseLocation.data[0]['result'] == 'ok' &&
          responseLocation.data[1]['data'].isNotEmpty &&
          responseLocation.data[1]['data'][0]['operation_status'] == 0) {
        final location =
            responseLocation.data[1]['data'][0]['current_location'];
        final latitude = location.split(',')[0];
        final longitude = location.split(',')[1];
        map['latitude'] = latitude;
        map['longitude'] = longitude;
      }

      if (responseRouteDetail.data.isNotEmpty &&
          responseRouteDetail.data[0]['result'] == 'ok' &&
          responseRouteDetail.data.length > 1 &&
          responseRouteDetail.data[1]['data'].isNotEmpty) {
        map['vehicle_name'] =
            responseRouteDetail.data[1]['data'][0]['vehicle_name'];
        map['reg_no'] = responseRouteDetail.data[1]['data'][0]['reg_no'];
        map['driver_name'] =
            responseRouteDetail.data[1]['data'][0]['driver_name'];
        map['contact1'] = responseRouteDetail.data[1]['data'][0]['contact1'];
        map['contact2'] = responseRouteDetail.data[1]['data'][0]['contact2'];
      }
    }
    return map;
  }

  _onDeleteTap(String routeId, List<RouteInfo> routes, String studentId) async {
    //userId
    final userId = await SharedPreferenceHelper.getUserNumber();
    final sessonId = await SharedPreferenceHelper.getUserSessionId();
    final oprId = routes.first.oprid;
    Logger().i(
      'Delete tapped for route $routeId, userId: $userId, oprId: $oprId, sessonId: $sessonId',
    );
    // run api to delete/remove the route
    ApiManager()
        .post(
          'ktuserstdroutedel/',
          data: {
            'student_id': studentId,
            'oprid': oprId,
            'sessionid': sessonId,
            'userid': userId,
          },
        )
        .then((response) {
          if (response.statusCode == 200) {
            Logger().i(response.data);
            if (response.data[0]['result'] == 'ok') {
              if (response.data[1]['data'] == 'ok') {
                setState(() {
                  _isLoading = true;
                });
                _fetchChildren();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Delete tapped for route $routeId')),
                );
              }
            }
          }
        });
  }

  void _showLocationAndRouteDialog(Map<String, dynamic> map) {
    showDialog(
      context: context,
      builder: (context) => LocationAndRouteDialog(
        latitude: double.tryParse(map['latitude'] ?? '0') ?? 0.0,
        longitude: double.tryParse(map['longitude'] ?? '0') ?? 0.0,
        vehicleName: map['vehicle_name'] ?? '',
        regNo: map['reg_no'] ?? '',
        driverName: map['driver_name'] ?? '',
        contact1: map['contact1'] ?? '',
        contact2: map['contact2'] ?? '',
      ),
    );
  }
}
