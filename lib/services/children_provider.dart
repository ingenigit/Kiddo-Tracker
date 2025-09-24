import 'package:flutter/material.dart';
import 'package:kiddo_tracker/model/child.dart';
import 'package:kiddo_tracker/model/subscribe.dart';
import 'package:kiddo_tracker/mqtt/MQTTService.dart';
import 'package:kiddo_tracker/widget/sqflitehelper.dart';
import 'package:logger/logger.dart';

class ChildrenProvider with ChangeNotifier {
  List<Child> _children = [];
  Map<String, SubscriptionPlan> _studentSubscriptions = {};
  List<Map<String, dynamic>> activities = [];
  final SqfliteHelper _sqfliteHelper = SqfliteHelper();
  MQTTService? _mqttService;

  List<Child> get children => _children;
  Map<String, SubscriptionPlan> get studentSubscriptions =>
      _studentSubscriptions;
  List<Map<String, dynamic>> get activitiesList => activities;
  MQTTService? get mqttService => _mqttService;

  void setMqttService(MQTTService service) {
    _mqttService = service;
  }

  Future<void> updateChildren() async {
    try {
      final childrenMaps = await _sqfliteHelper.getChildren();
      final subscriptionsMaps = await _sqfliteHelper.getStudentSubscriptions();

      _children = childrenMaps.map((map) => Child.fromJson(map)).toList();
      _studentSubscriptions = {
        for (var map in subscriptionsMaps)
          map['student_id'] as String: SubscriptionPlan.fromJson(map),
      };

      notifyListeners();
    } catch (e) {
      Logger().e('Error updating children: $e');
    }
  }

  void updateChildOnboardStatus(String studentId, int status) {
    final childIndex = _children.indexWhere(
      (child) => child.studentId == studentId,
    );
    if (childIndex != -1) {
      _children[childIndex] = Child(
        studentId: _children[childIndex].studentId,
        name: _children[childIndex].name,
        nickname: _children[childIndex].nickname,
        school: _children[childIndex].school,
        class_name: _children[childIndex].class_name,
        rollno: _children[childIndex].rollno,
        age: _children[childIndex].age,
        gender: _children[childIndex].gender,
        tagId: _children[childIndex].tagId,
        routeInfo: _children[childIndex].routeInfo,
        tsp_id: _children[childIndex].tsp_id,
        status: _children[childIndex].status,
        onboard_status: status,
      );
      notifyListeners();
    }
  }

  Future<void> subscribeToTopics({MQTTService? mqttService}) async {
    final service = mqttService ?? _mqttService;
    if (service == null) return;

    if (service.subscribedTopics.isNotEmpty) {
      service.unsubscribeFromAllTopics();
    }

    Set<String> topicSet = {};
    topicSet.addAll(_children.map((child) => child.studentId));
    for (var child in _children) {
      topicSet.addAll(
        child.routeInfo.map((route) => '${route.routeId}/${route.oprId}'),
      );
    }

    List<String> topics = topicSet.toList();
    service.subscribeToTopics(topics);
  }

  Future<void> removeChildOrRouteOprid(
    String type,
    String studentId, {
    MQTTService? mqttService,
  }) async {
    final service = mqttService ?? _mqttService;
    if (service == null) return;

    // Find the child to remove
    final childIndex = _children.indexWhere(
      (child) => child.studentId == studentId,
    );
    if (childIndex == -1) return;

    final childToRemove = _children[childIndex];
    Set<String> topicsToUnsubscribe = {};
    // Calculate topics to unsubscribe
    if (type == 'child') {
      topicsToUnsubscribe = {childToRemove.studentId};
    } else {
      topicsToUnsubscribe.addAll(
        childToRemove.routeInfo.map(
          (route) => '${route.routeId}/${route.oprId}',
        ),
      );
    }
    // Remove child from list
    // _children.removeAt(childIndex);

    // Unsubscribe from removed topics
    service.unsubscribeFromTopics(topicsToUnsubscribe.toList());

    // Re-subscribe to remaining topics

    // Update database if needed (assuming SqfliteHelper has a delete method)
    // await _sqfliteHelper.deleteChild(studentId);

    notifyListeners();
  }

  Future<void> updateActivity() async {
    try {
      final activityMaps = await _sqfliteHelper.getActivities();
      activities = activityMaps.map((map) => map).toList();
      notifyListeners();
    } catch (e) {
      Logger().e('Error updating children: $e');
    }
  }
}
