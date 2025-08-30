import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kiddo_tracker/api/apimanage.dart';
import 'package:kiddo_tracker/model/child.dart';
import 'package:kiddo_tracker/model/parent.dart';
import 'package:kiddo_tracker/model/route.dart';
import 'package:kiddo_tracker/widget/sqflitehelper.dart';
import 'package:logger/logger.dart';

import '../routes/routes.dart';

class OTPScreen extends StatefulWidget {
  String? mobile;
  OTPScreen({super.key, this.mobile});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final ApiManager apiManager = ApiManager();
  final Logger logger = Logger();

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _signIn() {
    final otp = _controllers.map((c) => c.text).join();
    // Handle OTP sign in logic here
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${widget.mobile} OTP: $otp')));
    //using apiManager to verify otp and navigate to next screen on success
    String mobileNumber = widget.mobile ?? '';
    List<Map<String, dynamic>> data = [
      {
          "result": "ok"
      },
      {
          "userdata": [
              {
                  "userid": "8456029772",
                  "name": "Suman",
                  "city": "bbsr",
                  "state": "Odisha",
                  "address": "bbsr",
                  "contact": "8456029772",
                  "email": "suman@gmail.com",
                  "mobile": "8456029772",
                  "wards": 0,
                  "status": 0,
                  "sessionid": "570318456029772"
              }
          ]
      },
      {
          "studentdata": [
              {
                  "student_id": "OD23264262",
                  "name": "Suman shrestha",
                  "nickname": "Suman",
                  "school": "Dav unit 8",
                  "class": "2",
                  "rollno": "2",
                  "age": 8,
                  "gender": "Male",
                  "tag_id": "",
                  "route_info": "[{\"route_id\":\"OR76295500001\",\"route_name\":\"Route 1\",\"oprid\":\"7\",\"vehicle_id\":\"1234\",\"stop_id\":\"7\",\"stop_name\":\"Baramunda\",\"stop_arrival_time\":\"11:22:00\"},\"{\\\"route_id\\\": \\\"OR76295500002\\\",\\\"route_name\\\": \\\"Route 1\\\",\\\"oprid\\\": \\\"9\\\",\\\"vehicle_id\\\": \\\"OD33AK9301\\\",\\\"stop_id\\\": \\\"13\\\",\\\"stop_name\\\": \\\"Baramunda\\\",\\\"stop_arrival_time\\\": \\\"11:00:00\\\"}\"]",
                  "status": 0,
                  "onboard_status": 0
              },
              {
                  "student_id": "OD65394086",
                  "name": "Ratan",
                  "nickname": "ratan",
                  "school": "Dav unit 8",
                  "class": "2",
                  "rollno": "2",
                  "age": 8,
                  "gender": "Male",
                  "tag_id": "FF:FF:11:94:D9:F2",
                  "route_info": "[{\"route_id\":\"OR76295500001\",\"route_name\":\"Route 1\",\"oprid\":\"7\",\"vehicle_id\":\"1234\",\"stop_id\":\"5\",\"stop_name\":\"Delta Square\",\"stop_arrival_time\":\"11:22:00\"},\"{\\\"route_id\\\": \\\"OR76295500002\\\",\\\"route_name\\\": \\\"Route 1\\\",\\\"oprid\\\": \\\"9\\\",\\\"vehicle_id\\\": \\\"OD33AK9301\\\",\\\"stop_id\\\": \\\"14\\\",\\\"stop_name\\\": \\\"Fire Station Square\\\",\\\"stop_arrival_time\\\": \\\"11:00:00\\\"}\",\"{\\\"route_id\\\": \\\"OR49401200001\\\",\\\"route_name\\\": \\\"Route 5\\\",\\\"oprid\\\": \\\"11\\\",\\\"vehicle_id\\\": \\\"OR404910001\\\",\\\"stop_id\\\": \\\"11\\\",\\\"stop_name\\\": \\\"Laxmiposi\\\",\\\"stop_arrival_time\\\": \\\"12:20:00\\\"}\",\"{\\\"route_id\\\": \\\"OR40491000001\\\",\\\"route_name\\\": \\\"Route1\\\",\\\"oprid\\\": \\\"1\\\",\\\"vehicle_id\\\": \\\"OD-01-2635\\\",\\\"stop_id\\\": \\\"3\\\",\\\"stop_name\\\": \\\"Baramunda\\\",\\\"stop_arrival_time\\\": \\\"09:00:00\\\"}\"]",
                  "status": 1,
                  "onboard_status": 0
              },
              {
                  "student_id": "OD86015821",
                  "name": "New",
                  "nickname": "new",
                  "school": "Dav",
                  "class": "2",
                  "rollno": "2",
                  "age": 8,
                  "gender": "Other",
                  "tag_id": "",
                  "route_info": "",
                  "status": 0,
                  "onboard_status": 0
              }
          ]
      }
    ];

    logger.i(data);
    if (data[0]['result'] == 'ok') {
      SqfliteHelper().clearAllData();
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
      logger.i(parent.toJson().toString());
      SqfliteHelper().insertUser(parent);
      //////////////////////////////////////////////////////////////
      for (var student in studentInfo) {
        logger.i(student.toString());
        List<RouteInfo> parsedRouteInfo = [];
        if (student['route_info'] != null) {
          if (student['route_info'] is String && (student['route_info'] as String).isNotEmpty) {
            try {
              var decoded = jsonDecode(student['route_info']);
              if (decoded is List) {
                parsedRouteInfo = decoded
                    .map<RouteInfo>(
                      (e) => RouteInfo.fromJson(
                        e is String ? jsonDecode(e) : e as Map<String, dynamic>,
                      ),
                    )
                    .toList();
              }
            } catch (e) {
              logger.e("Error parsing route_info: $e");
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
          user_id: userInfo[0]['userid'],
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
        );
        logger.i(child.toJson().toString());
        SqfliteHelper().insertChild(child);
      }
      Navigator.pushNamed(context, AppRoutes.main);
    }

  //   apiManager
  //       .post(
  //         'ktrackuserverifyotp/',
  //         data: {'mobile': mobileNumber, 'otpval': otp},
  //       )
  //       .then((response) {
  //         if (response.statusCode == 200) {
  //           logger.i(response.toString());
  //           if (response.data[0]['result'] == 'ok') {
  //             // print response
  //             print(response.toString());
  //             // On success, call another api to check if user exists
  //             apiManager
  //                 .post(
  //                   'ktrackuserbymobile/',
  //                   data: {
  //                     'passkey': "Usr.KdTrac4\$Dat",
  //                     'mobile': mobileNumber,
  //                   },
  //                 )
  //                 .then((response) {
  //                   if (response.statusCode == 200) {
  //                     final data = response.data;
  //                     logger.i(data);
  //                     if (data[0]['result'] == 'ok') {
  //                       //before save to sqflite, clear all data from sqflite
  //                       SqfliteHelper().clearAllData();
  //                       logger.i(data);
  //                       // Save to SqfliteHelper using insertUser method
  //                       final List userInfo = List.from(
  //                         data[1]['userdata'] as List<dynamic>? ?? [],
  //                       );
  //                       logger.i(userInfo);
  //                       Parent parent = Parent(
  //                         userid: userInfo[0]['userid'],
  //                         name: userInfo[0]['name'],
  //                         city: userInfo[0]['city'],
  //                         state: userInfo[0]['state'],
  //                         address: userInfo[0]['address'],
  //                         contact: userInfo[0]['contact'],
  //                         email: userInfo[0]['email'],
  //                         mobile: userInfo[0]['mobile'],
  //                         wards: userInfo[0]['wards'],
  //                         status: userInfo[0]['status'],
  //                         sessionid: userInfo[0]['sessionid'],
  //                       );
  //                       logger.i(parent.toJson().toString());
  //                       SqfliteHelper().insertUser(parent);

  //                       final List studentInfo = List.from(
  //                         data[2]['studentdata'] as List<dynamic>? ?? [],
  //                       );
  //                       for (var student in studentInfo) {
  //                         logger.i(student.toString());
  //                         List<RouteInfo> parsedRouteInfo = [];
  //                         if (student['route_info'] != null) {
  //                           if (student['route_info'] is String &&
  //                               (student['route_info'] as String).isNotEmpty) {
  //                             try {
  //                               var decoded = jsonDecode(student['route_info']);
  //                               if (decoded is List) {
  //                                 parsedRouteInfo = decoded
  //                                     .map<RouteInfo>(
  //                                       (e) => RouteInfo.fromJson(
  //                                         e is String
  //                                             ? jsonDecode(e)
  //                                             : e as Map<String, dynamic>,
  //                                       ),
  //                                     )
  //                                     .toList();
  //                               }
  //                             } catch (e) {
  //                               logger.e("Error parsing route_info: $e");
  //                             }
  //                           } else if (student['route_info'] is List) {
  //                             parsedRouteInfo = (student['route_info'] as List)
  //                                 .map<RouteInfo>(
  //                                   (e) => RouteInfo.fromJson(
  //                                     e is String
  //                                         ? jsonDecode(e)
  //                                         : e as Map<String, dynamic>,
  //                                   ),
  //                                 )
  //                                 .toList();
  //                           }
  //                         }
  //                         Child child = Child(
  //                           user_id: userInfo[0]['userid'],
  //                           studentId: student['student_id'],
  //                           name: student['name'],
  //                           nickname: student['nickname'],
  //                           school: student['school'],
  //                           class_name: student['class'],
  //                           rollno: student['rollno'],
  //                           age: student['age'],
  //                           gender: student['gender'],
  //                           tagId: student['tag_id'],
  //                           routeInfo: parsedRouteInfo,
  //                           status: student['status'],
  //                         );
  //                         logger.i(child.toJson().toString());
  //                         SqfliteHelper().insertChild(child);
  //                       }

  //                       // User exists, navigate to main screen
  //                       Navigator.pushNamed(context, AppRoutes.main);
  //                       // Optionally, save user login state in shared preferences
  //                       // SharedPreferenceHelper.setUserLoggedIn(true);
  //                     } else {
  //                       // User does not exist, navigate to signup screen
  //                       Navigator.pushNamed(
  //                         context,
  //                         AppRoutes.signup,
  //                         arguments: mobileNumber,
  //                       );
  //                     }
  //                   } else {
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       SnackBar(
  //                         content: Text(
  //                           'Error checking user existence: ${response.statusMessage}',
  //                         ),
  //                       ),
  //                     );
  //                   }
  //                 })
  //                 .catchError((error) {
  //                   ScaffoldMessenger.of(
  //                     context,
  //                   ).showSnackBar(SnackBar(content: Text('Error: $error')));
  //                   logger.i(error.toString());
  //                 });
  //           } else {
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               SnackBar(content: Text('Error: ${response.data['message']}')),
  //             );
  //           }
  //           // Navigator.pushNamed(context, AppRoutes.otp);
  //         } else {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Text('Failed to send OTP: ${response.statusMessage}'),
  //             ),
  //           );
  //         }
  //       })
  //       .catchError((error) {
  //         ScaffoldMessenger.of(
  //           context,
  //         ).showSnackBar(SnackBar(content: Text('Error: $error')));
  //       });
  }

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Enter OTP',
                  style: TextStyle(
                    color: Color(0xFF755DC1),
                    fontSize: 24,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Please enter the OTP sent to your phone',
                  style: TextStyle(
                    color: Color(0xFF837E93),
                    fontSize: 16,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    return Container(
                      width: 48,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextField(
                        controller: _controllers[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(fontSize: 24),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF837E93),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF9F7BFF),
                              width: 2,
                            ),
                          ),
                          counterText: '',
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            node.nextFocus();
                          } else if (value.isEmpty && index > 0) {
                            node.previousFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9F7BFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
