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
  String Address = '';
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
    Address = '';
    session = '';
    children = [];
  }

  Future<void> _fetchUserData() async {
    List<Map<String, dynamic>> users = await sqfliteHelper.getUsers();
    List<Map<String, dynamic>> children = await sqfliteHelper.getChildren();
    setState(() {
      userName = users[0]['name'];
      mobileNumber = users[0]['mobile'];
      Address = users[0]['address'];
      session = users[0]['sessionid'];
      this.children = List.from(children);
    });
  }

  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Settings'),
      //   backgroundColor: Theme.of(context).primaryColor,
      //   foregroundColor: Colors.white,
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // User Profile Section
            Text(
              'User Profile',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Divider(
              thickness: 2,
              color: Theme.of(context).primaryColor.withOpacity(0.5),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 5),
                Icon(
                  Icons.person_4_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 35,
                ),
                SizedBox(width: 10),
                Text(
                  userName.isNotEmpty ? 'Suman Bahadur Shrestha' : 'Loading...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity( 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.phone,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                title: Text('Mobile'),
                subtitle: Text(mobileNumber),
              ),
              // ),
            ),
            SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading:Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity( 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                title: Text('Address'),
                subtitle: Text(Address),
              ),
            ),
            SizedBox(height: 30),
            // Children Section
            Text(
              'Children',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Divider(
              thickness: 2,
              color: Theme.of(context).primaryColor.withOpacity(0.5),
            ),
            // SizedBox(height: 10),
            // Text(
            //   'Total Children: ${children.length}',
            //   style: TextStyle(
            //     fontSize: 16,
            //     fontWeight: FontWeight.w500,
            //     color: Theme.of(context).primaryColorDark,
            //   ),
            // ),
            // SizedBox(height: 15),
            ...children.asMap().entries.map((entry) {
              int idx = entry.key;
              var child = entry.value;
              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColorLight,
                    child: Text(
                      child['name'][0].toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    child['name'],
                    style: TextStyle(fontWeight: FontWeight.w300, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Age: ${child['age']}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'School: ${child['school']}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Class: ${child['class_name']}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () => editChild(idx),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _confirmDeleteChild(idx),
                      ),
                    ],
                  ),
                ),
              );
            }),
            SizedBox(height: 30),
            // Preferences Section
            Text(
              'Preferences',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Divider(
              thickness: 2,
              color: Theme.of(context).primaryColor.withOpacity(0.5),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: Text('Dark Mode'),
                value: darkMode,
                onChanged: (val) {
                  setState(() {
                    darkMode = val;
                  });
                },
                secondary: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: Icon(
                    darkMode ? Icons.dark_mode : Icons.light_mode,
                    key: ValueKey<bool>(darkMode),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteChild(int idx) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Child'),
          content: Text('Are you sure you want to delete this child?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                deleteChild(idx);
              },
            ),
          ],
        );
      },
    );
  }

  void editChild(int idx) {
    final child = children[idx];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddChildScreen(childData: child, isEdit: true),
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
          Provider.of<ChildrenProvider>(
            context,
            listen: false,
          ).updateChildren();
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
