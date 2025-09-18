import 'package:flutter/material.dart';
import 'package:kiddo_tracker/api/apimanage.dart';
import 'package:kiddo_tracker/pages/addchildscreen.dart';
import 'package:kiddo_tracker/services/children_provider.dart';
import 'package:kiddo_tracker/widget/sqflitehelper.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  //use sqflite to get user details
  SqfliteHelper sqfliteHelper = SqfliteHelper();

  String userName = '';
  String mobileNumber = '';
  String session = '';
  List<Map<String, dynamic>> children = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    // Removed sqfliteHelper.close() to prevent closing the database while async operations are in progress
    super.dispose();
    // Removed clearAllData call to avoid clearing data prematurely
    // clearAllData();
  }

  void clearAllData() {
    userName = '';
    mobileNumber = '';
    session = '';
    children = [];
  }

  Future<void> _fetchUserData() async {
    List<Map<String, dynamic>> users = await sqfliteHelper.getUsers();
    List<Map<String, dynamic>> children = await sqfliteHelper.getChildren();
    setState(() {
      userName = users[0]['name'];
      mobileNumber = users[0]['mobile'];
      session = users[0]['sessionid'];
      this.children = List.from(children);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Text('User Name: $userName'),
              SizedBox(height: 8),
              Text('Mobile Number: $mobileNumber'),
              SizedBox(height: 16),
              Text('Children:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...children.asMap().entries.map((entry) {
                int idx = entry.key;
                var child = entry.value;
                return Card(
                  child: ListTile(
                    title: Text('${child['name']}'),
                    subtitle: Text('Age: ${child['age']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => editChild(idx),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => deleteChild(idx),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              SizedBox(height: 16),
              //   SwitchListTile(
              //     title: Text('Dark Mode'),
              //     value: darkMode,
              //     onChanged: (val) {
              //       setState(() {
              //         darkMode = val;
              //       });
              //     },
              //   ),
            ],
          ),
        ),
      ),
    );
  }

  void editChild(int idx) {
    final child = children[idx];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddChildScreen(
          childData: child,
          isEdit: true,
        ),
      ),
    ).then((value) {
      // Refresh the list after returning from AddChildScreen
      _fetchUserData();
    });
  }

  void deleteChild(int idx) async {
    final studentId = children[idx]['student_id'];

    final oprIdList = await sqfliteHelper.getAllRoutesByStudentId(studentId);
    final logOprIdList = oprIdList.isNotEmpty
        ? oprIdList.map((e) => '"$e"').toList().toString()
        : [];
    Logger().i(
      'Deleting child with ID: $studentId, user ID: $mobileNumber, session ID: $session, oprIdList: $logOprIdList',
    );
    try {
      var response = await ApiManager().post(
        'ktuserstddelete',
        data: {
          'userid': mobileNumber,
          'sessionid': session,
          'oprids': logOprIdList,
          'student_id': studentId,
        },
      );
      print('Delete child response: ${response.data}');
      if (response.statusCode == 200 && response.data[0]['result'] == 'ok') {
        int deletedCount = await sqfliteHelper.deleteChild(studentId);
        if (deletedCount > 0) {
          setState(() {
            children.removeAt(idx);
          });
          Provider.of<ChildrenProvider>(context, listen: false).updateChildren();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Child deleted successfully',
                style: TextStyle(color: Colors.green),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to delete child locally.',
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete child. Server error.',
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error deleting child: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error deleting child: $e',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }
  }
}
