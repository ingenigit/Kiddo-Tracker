import 'package:flutter/material.dart';
import 'package:kiddo_tracker/model/child.dart';
import 'package:kiddo_tracker/model/subscribe.dart';
import 'package:kiddo_tracker/mqtt/MQTTService.dart';
import 'package:kiddo_tracker/widget/sqflitehelper.dart';
import 'package:logger/logger.dart';

class ChildrenProvider with ChangeNotifier {
  List<Child> _children = [];
  Map<String, SubscriptionPlan> _studentSubscriptions = {};
  final SqfliteHelper _sqfliteHelper = SqfliteHelper();

  List<Child> get children => _children;
  Map<String, SubscriptionPlan> get studentSubscriptions =>
      _studentSubscriptions;

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

  Future<void> subscribeToTopics({required MQTTService mqttService}) async {
    if (mqttService.subscribedTopics.isNotEmpty) {
      mqttService.unsubscribeFromAllTopics();
    }

    List<String> topics = _children.map((child) => child.studentId).toList();
    for (var child in _children) {
      topics.addAll(
        child.routeInfo.map((route) => '${route.routeId}/${route.oprId}'),
      );
    }

    mqttService.subscribeToTopics(topics);
  }
}
