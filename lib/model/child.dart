import 'dart:convert';
import 'package:kiddo_tracker/model/route.dart';

class Child {
  final String user_id;
  final String studentId;
  final String name;
  final String nickname;
  final String school;
  final String class_name;
  final String rollno;
  final int age;
  final String gender;
  final String tagId;
  final List<RouteInfo> routeInfo;
  final int status;

  Child({
    required this.user_id,
    required this.studentId,
    required this.name,
    required this.nickname,
    required this.school,
    required this.class_name,
    required this.rollno,
    required this.age,
    required this.gender,
    required this.tagId,
    required this.routeInfo,
    required this.status,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    List<RouteInfo> routes = [];
    if (json['route_info'] != null) {
      if (json['route_info'] is String) {
        try {
          var decoded = jsonDecode(json['route_info']);
          if (decoded is List) {
            routes = decoded
                .map<RouteInfo>(
                  (e) => RouteInfo.fromJson(
                    e is String ? jsonDecode(e) : e as Map<String, dynamic>,
                  ),
                )
                .toList();
          }
        } catch (_) {}
      } else if (json['route_info'] is List) {
        routes = (json['route_info'] as List)
            .map<RouteInfo>(
              (e) => RouteInfo.fromJson(
                e is String ? jsonDecode(e) : e as Map<String, dynamic>,
              ),
            )
            .toList();
      }
    }

    return Child(
      user_id: json['user_id'] ?? '',
      studentId: json['student_id'] ?? '',
      name: json['name'] ?? '',
      nickname: json['nickname'] ?? '',
      school: json['school'] ?? '',
      class_name: json['class_name']?.toString() ?? '',
      rollno: json['rollno']?.toString() ?? '',
      age: json['age'] is int
          ? json['age']
          : int.tryParse(json['age'].toString()) ?? 0,
      gender: json['gender'] ?? '',
      tagId: json['tag_id'] ?? '',
      routeInfo: routes,
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status'].toString()) ?? 0,
    );
  }

  get student_id => studentId;

  Map<String, dynamic> toJson() => {
    'user_id': user_id,
    'student_id': studentId,
    'name': name,
    'nickname': nickname,
    'school': school,
    'class_name': class_name,
    'rollno': rollno,
    'age': age,
    'gender': gender,
    'tag_id': tagId,
    'route_info': jsonEncode(routeInfo.map((e) => e.toJson()).toList()),
    'status': status,
  };
}
