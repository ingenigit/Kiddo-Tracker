import 'package:flutter/material.dart';
import 'package:kiddo_tracker/api/apimanage.dart';
import 'package:kiddo_tracker/routes/routes.dart';
import 'package:kiddo_tracker/widget/shareperference.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _wardsController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  @override
  void dispose() {
    _userIdController.dispose();
    _nameController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _wardsController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      //call apimanager
      ApiManager()
          .post(
            'ktrackusersignup',
            data: {
              'userid': _userIdController.text,
              'name': _nameController.text,
              'city': _cityController.text,
              'state': _stateController.text,
              'address': _addressController.text,
              'contact': _contactController.text,
              'email': _emailController.text,
              'mobile': _mobileController.text,
              'wards': _wardsController.text,
              'status': _statusController.text,
            },
          )
          .then((response) {
            if (response.statusCode == 200) {
              if (response.data[0]['result'] == 'ok') {
                SharedPreferenceHelper.setUserSessionId(
                  response.data[1]['sessionid'],
                );
                Navigator.pushNamed(context, AppRoutes.main);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sign up successful')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${response.data['message']}')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Failed to send OTP: ${response.statusMessage}',
                  ),
                ),
              );
            }
          });
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(label: 'User ID', controller: _userIdController),
              _buildTextField(label: 'Name', controller: _nameController),
              _buildTextField(label: 'City', controller: _cityController),
              _buildTextField(label: 'State', controller: _stateController),
              _buildTextField(label: 'Address', controller: _addressController),
              _buildTextField(label: 'Contact', controller: _contactController),
              _buildTextField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField(
                label: 'Mobile',
                controller: _mobileController,
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(label: 'Wards', controller: _wardsController),
              _buildTextField(label: 'Status', controller: _statusController),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _submit, child: const Text('Sign Up')),
            ],
          ),
        ),
      ),
    );
  }
}
