import 'package:flutter/material.dart';
import 'package:kiddo_tracker/api/apimanage.dart';
import 'package:kiddo_tracker/widget/shareperference.dart';
import 'package:logger/logger.dart';

import '../routes/routes.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  _AddChildScreenState createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _rollNoController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String? gender;

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
    final name = _nameController.text;
    final nickname = _nicknameController.text;
    final school = _schoolController.text;
    final className = _classNameController.text;
    final rollNo = _rollNoController.text;
    final age = _ageController.text;
    final state = _stateController.text;
    //validate the form data
    if (name.isEmpty ||
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
        'Name: $name, Nickname: $nickname, School: $school, Class: $className, Roll No: $rollNo, State: $state, Gender: $gender',
      );
      //submit the form data
      final response = await ApiManager().post(
        'ktuseraddstudent',
        data: {
          'userid': userId,
          'sessionid': sessionId,
          'name': name,
          'nickname': nickname,
          'school': school,
          'class': className,
          'rollno': rollNo,
          'gender': gender,
          'age': age,
          'state': state,
        },
      );
      final data = response.data;
      Logger().i(data);
      if (data[0]['result'] == 'ok') {
        _showSnackBar('Child added successfully', Colors.green);
        //back to home screen
        Navigator.pop(context);
        //refresh the home screen
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      } else {
        _showSnackBar('Error adding child', Colors.red);
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
                child: Text('Add Child'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
