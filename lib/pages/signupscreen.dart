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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      //call apimanager
      ApiManager()
          .post(
            'ktrackusersignup',
            data: {
              'userid': _contactController.text,
              'name': _nameController.text,
              'city': _cityController.text,
              'state': _stateController.text,
              'address': _addressController.text,
              'contact': _contactController.text,
              'email': _emailController.text,
              'mobile': _mobileController.text,
              'wards': "",
              'status': "",
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
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Create Your Account',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                          label: 'Name',
                          controller: _nameController,
                          icon: Icons.person,
                        ),
                        _buildTextField(
                          label: 'Mobile No.',
                          controller: _contactController,
                          icon: Icons.phone,
                        ),
                        _buildTextField(
                          label: 'Email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          icon: Icons.email,
                        ),
                        _buildTextField(
                          label: 'Other Number',
                          controller: _mobileController,
                          keyboardType: TextInputType.phone,
                          icon: Icons.phone_android,
                        ),
                        _buildTextField(
                          label: 'Address',
                          controller: _addressController,
                          icon: Icons.home,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: 'City',
                                controller: _cityController,
                                keyboardType: TextInputType.streetAddress,
                                icon: Icons.location_city,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                label: 'State',
                                controller: _stateController,
                                icon: Icons.map,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 18),
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
