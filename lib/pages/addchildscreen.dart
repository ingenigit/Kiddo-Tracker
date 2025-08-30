import 'package:flutter/material.dart';

class AddChildScreen extends StatefulWidget {

  const AddChildScreen({super.key,});

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

  String? gender;

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _schoolController.dispose();
    _classNameController.dispose();
    _rollNoController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _validateAndSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      _showSnackBar('Child added!');
      // Add backend logic here
    } else {
      _showSnackBar('Please fix the errors in red');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Child'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter name' : null,
              ),
              TextFormField(
                controller: _nicknameController,
                decoration: InputDecoration(labelText: 'Nickname'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter nickname' : null,
              ),
              TextFormField(
                controller: _schoolController,
                decoration: InputDecoration(labelText: 'School'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter school' : null,
              ),
              TextFormField(
                controller: _classNameController,
                decoration: InputDecoration(labelText: 'Class'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter class' : null,
              ),
              TextFormField(
                controller: _rollNoController,
                decoration: InputDecoration(labelText: 'Roll No'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter roll no';
                  if (int.tryParse(value) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Gender'),
                value: gender,
                items: ['Male', 'Female', 'Other']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (value) => setState(() => gender = value),
                validator: (value) => value == null ? 'Select gender' : null,
              ),
              TextFormField(
                controller: _stateController,
                decoration: InputDecoration(labelText: 'State'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter state' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _validateAndSubmit,
                child: Text('Add Child'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}