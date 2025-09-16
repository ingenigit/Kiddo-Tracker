import 'package:flutter/material.dart';
import 'package:kiddo_tracker/api/apimanage.dart';
import 'package:kiddo_tracker/model/child.dart';
import 'package:kiddo_tracker/services/children_provider.dart';
import 'package:kiddo_tracker/widget/shareperference.dart';
import 'package:kiddo_tracker/widget/sqflitehelper.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:provider/provider.dart';

import '../routes/routes.dart';

class AddChildScreen extends StatefulWidget {
  final Map<String, dynamic>? childData;
  final bool isEdit;

  const AddChildScreen({super.key, this.childData, this.isEdit = false});

  @override
  _AddChildScreenState createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  SqfliteHelper db = SqfliteHelper();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _rollNoController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String? gender;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.childData != null) {
      _nameController.text = widget.childData!['name'] ?? '';
      _nicknameController.text = widget.childData!['nickname'] ?? '';
      _schoolController.text = widget.childData!['school'] ?? '';
      _classNameController.text = widget.childData!['class_name'] ?? '';
      _rollNoController.text = widget.childData!['rollno'] ?? '';
      _stateController.text = widget.childData!['state'] ?? '';
      _ageController.text = widget.childData!['age']?.toString() ?? '';
      gender = widget.childData!['gender'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _schoolController.dispose();
    _classNameController.dispose();
    _rollNoController.dispose();
    _ageController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, [Color? color]) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  void _validateAndSubmit() async {
    //get the form data
    final String? userId = await SharedPreferenceHelper.getUserNumber();
    final String? sessionId = await SharedPreferenceHelper.getUserSessionId();
    final childname = _nameController.text;
    final nickname = _nicknameController.text;
    final school = _schoolController.text;
    final className = _classNameController.text;
    final rollNo = _rollNoController.text;
    final age = _ageController.text;
    final state = _stateController.text;
    Logger().i(
      'name: $childname, nickname: $nickname, school: $school, class: $className, rollNo: $rollNo, age: $age, state: $state, gender: $gender',
    );
    //validate the form data
    if (childname.isEmpty ||
        nickname.isEmpty ||
        school.isEmpty ||
        className.isEmpty ||
        rollNo.isEmpty ||
        state.isEmpty) {
      _showSnackBar('Please fill in all fields', Colors.red);
    } else {
      //print
      Logger().i('userid: $userId');
      Logger().i('sessionid: $sessionId');
      Logger().i(
        'Name: $childname, Nickname: $nickname, School: $school, Class: $className, Roll No: $rollNo, State: $state, Gender: $gender',
      );

      final apiEndpoint = widget.isEdit
          ? 'ktuserstudentedit'
          : 'ktuseraddstudent';

      final response = await ApiManager().post(
        apiEndpoint,
        data: {
          'userid': userId,
          'sessionid': sessionId,
          'name': childname,
          'nickname': nickname,
          'school': school,
          'class': className,
          'rollno': rollNo,
          'gender': gender,
          'age': age,
          'state': state,
          if (widget.isEdit) 'student_id': widget.childData?['student_id'],
        },
      );
      final data = response.data;
      Logger().i(data);
      if (data[0]['result'] == 'ok') {
        final int parsedAge = int.parse(age);
        if (!widget.isEdit) {
          //add new child in database
          final studentId = data[1]['data']['student_id'] ?? '';
          final child = Child(
            studentId: studentId,
            name: childname,
            nickname: nickname,
            school: school,
            class_name: className,
            rollno: rollNo,
            age: parsedAge,
            gender: gender ?? '',
            tagId: "",
            routeInfo: [],
            status: 0,
            onboard_status: 0,
          );
          // save child to database
          await db.insertChild(child);
          //show child data
          Logger().i(child.toJson());
          Logger().i('Child added successfully');
        } else {
          // update existing child in database
          final studentId = widget.childData?['student_id'] ?? '';
          final child = Child(
            studentId: studentId,
            name: childname,
            nickname: nickname,
            school: school,
            class_name: className,
            rollno: rollNo,
            age: parsedAge,
            gender: gender ?? '',
            tagId: widget.childData?['tagId'] ?? '',
            routeInfo: widget.childData?['routeInfo'] ?? [],
            status: widget.childData?['status'] ?? 0,
            onboard_status: widget.childData?['onboard_status'] ?? 0,
          );
          await db.updateChild(child);
          Logger().i('Child updated successfully');
        }
        _showSnackBar(
          widget.isEdit
              ? 'Child updated successfully'
              : 'Child added successfully',
          Colors.green,
        );
        // clear all the text fields
        clearAllField();
        // update the list of children in the HomeScreen
        Provider.of<ChildrenProvider>(context, listen: false).updateChildren();
        //back to home screen
        // Navigator.pushNamedAndRemoveUntil(
        //   context,
        //   AppRoutes.main,
        //   (route) => false,
        // );
      } else {
        _showSnackBar(
          widget.isEdit ? 'Error updating child' : 'Error adding child',
          Colors.red,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Text(
                      //   'Child Information',
                      //   style: TextStyle(
                      //     fontSize: 20,
                      //     fontWeight: FontWeight.bold,
                      //     color: Theme.of(context).primaryColor,
                      //   ),
                      // ),
                      // SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter name'
                            : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _nicknameController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: 'Nickname',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter nickname'
                            : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _schoolController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: 'School Name',
                          prefixIcon: Icon(Icons.school),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter school'
                            : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _classNameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'Class',
                          prefixIcon: Icon(Icons.class_),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter class'
                            : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _rollNoController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Roll No',
                          prefixIcon: Icon(Icons.numbers),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter roll no';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Enter a valid number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Gender',
                          prefixIcon: Icon(Icons.wc),
                          border: OutlineInputBorder(),
                        ),
                        value: gender,
                        items: ['Male', 'Female', 'Other']
                            .map(
                              (g) => DropdownMenuItem(value: g, child: Text(g)),
                            )
                            .toList(),
                        onChanged: (value) => setState(() => gender = value),
                        validator: (value) =>
                            value == null ? 'Select gender' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Age',
                          prefixIcon: Icon(Icons.calendar_month),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Enter age' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _stateController,
                        keyboardType: TextInputType.streetAddress,
                        decoration: InputDecoration(
                          labelText: 'State',
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter state'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _validateAndSubmit,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text(widget.isEdit ? 'Update Child' : 'Add Child'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void clearAllField() {
    _nameController.clear();
    _nicknameController.clear();
    _schoolController.clear();
    _classNameController.clear();
    _rollNoController.clear();
    _ageController.clear();
    _stateController.clear();
    gender = null;
  }
}
