import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kiddo_tracker/api/apimanage.dart';
import 'package:kiddo_tracker/api/route_search_callback.dart';
import 'package:kiddo_tracker/model/route.dart';
import 'package:kiddo_tracker/model/routelist.dart';
import 'package:kiddo_tracker/services/children_provider.dart';
import 'package:kiddo_tracker/widget/shareperference.dart';
import 'package:kiddo_tracker/widget/sqflitehelper.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class AddChildRoutePage extends StatefulWidget {
  String? nickName;
  String? stdId;
  AddChildRoutePage({super.key, this.stdId, this.nickName});
  @override
  _AddChildRoutePageState createState() => _AddChildRoutePageState();
}

class _AddChildRoutePageState extends State<AddChildRoutePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _instituteController = TextEditingController();
  IconData _searchIcon = Icons.search;

  String? _userId;
  String? _sessionId;
  List<dynamic>? _institutes = [];
  String? _selectedInstitute;

  final List<RouteList> _routes = [];
  List<String> _times = [];
  List<Map<String, String>> _stopages = [];

  String? _selectedRoute;
  String? _selectedRouteName;
  String? _selectedRouteId;
  String? _selectedTime;
  String? _selectedorpId;
  String? _selectedStopage;
  String? _selectedStopageName;
  String? _stopageId;
  String? _vehicleId;
  //callback
  RouteSearchCallback callback = RouteSearchCallback();

  @override
  void dispose() {
    _instituteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      //show all value of Institute, Route, Time, Stopage
      Logger().i(
        'userid: $_userId, sessionid: $_sessionId, student_id: ${widget.stdId}, tsp_id: $_selectedInstitute, Route_id: $_selectedRouteId, route_name: $_selectedRouteName, stop_arrival_time: $_selectedTime, stop_name: $_selectedStopageName, oprid: $_selectedorpId, vehicle_id: $_vehicleId, stop_id: $_stopageId',
      );
      // Add backend logic here
      ApiManager()
          .post(
            'ktuassignstdtoroute',
            data: {
              'userid': _userId,
              'sessionid': _sessionId,
              'student_id': widget.stdId,
              'route_id': _selectedRouteId,
              'route_name': _selectedRouteName,
              'oprid': _selectedorpId,
              'vehicle_id': _vehicleId,
              'stop_id': _stopageId,
              'stop_name': _selectedStopageName,
              'stop_arrival_time': _selectedTime,
              'tsp_id': _selectedInstitute,
            },
          )
          .then((response) async {
            if (response.statusCode == 200) {
              Logger().i(response.data);
              if (response.data[0]['result'] == 'ok') {
                if (response.data[1]['data'] == 'ok') {
                  if (widget.stdId != null) {
                    final sqfliteHelper = SqfliteHelper();
                    // Get existing routes
                    final existingRouteStr = await sqfliteHelper.getRouteInfoByStudentId(widget.stdId!);
                    List<RouteInfo> routeList = [];
                    if (existingRouteStr != null && existingRouteStr.isNotEmpty) {
                      try {
                        final decoded = jsonDecode(existingRouteStr);
                        if (decoded is List) {
                          routeList = decoded.map<RouteInfo>((e) => RouteInfo.fromJson(e is String ? jsonDecode(e) : e as Map<String, dynamic>)).toList();
                        }
                      } catch (e) {
                        Logger().e('Error decoding existing routes: $e');
                      }
                    }
                    // Add new route
                    routeList.add(RouteInfo(
                      routeId: _selectedRouteId ?? '',
                      routeName: _selectedRouteName ?? '',
                      stopArrivalTime: _selectedTime ?? '',
                      stopName: _selectedStopageName ?? '',
                      oprId: _selectedorpId ?? '',
                      vehicleId: _vehicleId ?? '',
                      stopId: _stopageId ?? '',
                    ));
                    // make the routeList inside String
                    Logger().i(routeList.map((e) => e.toJson()).toList());
                    final newRoute = jsonEncode(routeList.map((e) => e.toJson()).toList());
                    Logger().i(newRoute);
                    await sqfliteHelper.updateRouteInfoByStudentId(
                      widget.stdId!,
                      newRoute,
                    );
                    Provider.of<ChildrenProvider>(
                      context,
                      listen: false,
                    ).updateChildren();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("New Route Added Successfully.")),
                    );
                  } else {
                    // Handle the case when widget.stdId is null
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: widget.stdId is null')),
                    );
                  }
                  // Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${response.data[1]['data']}'),
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Data not saved.")));
              }
            }
          });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fix the errors in red')));
    }
  }

  Widget _buildInstituteField() {
    return TextFormField(
      controller: _instituteController,
      decoration: InputDecoration(
        labelText: 'Institute',
        suffixIcon: IconButton(
          //check icon is search or clear
          icon: Icon(_searchIcon),
          onPressed: () {
            if (_searchIcon == Icons.search) {
              searchInstitite();
            } else {
              //clear all
              _instituteController.clear();
              reset_all();
              _searchIcon = Icons.search;
              //set focus on institute field
              FocusScope.of(context).requestFocus(FocusNode());
            }
          },
        ),
        border: OutlineInputBorder(),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Enter institute' : null,
    );
  }

  Widget _buildRouteDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Route No',
        border: OutlineInputBorder(),
      ),
      value: _selectedRoute,
      items: callback
          .getRouteNames()
          .map(
            (route) =>
                DropdownMenuItem<String>(value: route, child: Text(route)),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedRoute = value;
          if (value != null) {
            try {
              var selectedRoute = _routes.firstWhere((r) {
                String display =
                    "${r.routeName ?? r.routeId} ${r.type == 1 ? "OnWard" : "Return"}";
                return display == value;
              });
              _selectedRouteName = selectedRoute.routeName;
              Logger().i(selectedRoute.toJson());
              _selectedRouteId = selectedRoute.routeId;
              _times = callback.getRouteTimings(_selectedRouteId!);
              _stopages = (selectedRoute.stopDetails ?? []).map((stop) {
                return {
                  'key': stop.id,
                  'value': stop.stopName,
                  'time': '(${stop.arrival} - ${stop.departure})',
                };
              }).toList();
            } catch (e) {
              _selectedRouteId = null;
              _times = [];
              _stopages = [];
            }
          } else {
            _selectedRouteId = null;
            _times = [];
            _stopages = [];
          }
          _selectedTime = null;
          _selectedStopage = null;
          _selectedStopageName = null;
        });
      },
      validator: (value) => value == null ? 'Select a route' : null,
    );
  }

  Widget _buildTimeDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Time',
        border: OutlineInputBorder(),
      ),
      value: _selectedTime,
      items: _times
          .map((time) => DropdownMenuItem(value: time, child: Text(time)))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedTime = value;
          _selectedorpId = callback
              .getOprIdbyTiming(value!, _selectedRouteId!)
              .toString();
          _vehicleId = callback
              .getVehicleIdbyTiming(value, _selectedRouteId!)
              .toString();
        });
      },
      validator: (value) => value == null ? 'Select a time' : null,
    );
  }

  Widget _buildStopageSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Stopage:', style: TextStyle(fontWeight: FontWeight.bold)),
        ..._stopages.map(
          (stopage) => RadioListTile<String>(
            title: Text('${stopage['value']} ${stopage['time']}'),
            value: stopage['value']!,
            groupValue: _selectedStopage,
            onChanged: (value) {
              setState(() {
                _selectedStopage = value;
                _selectedStopageName = value;
                _stopageId = stopage['key'];
              });
            },
          ),
        ),
        if (_selectedStopage == null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Please select a stopage',
              style: TextStyle(color: Colors.red[700], fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () {
        if (_selectedStopage == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Please select a stopage')));
          return;
        }
        _submit();
      },
      child: Text('Add Route'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Route for ${widget.nickName}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildInstituteField(),
              SizedBox(height: 16),
              _buildRouteDropdown(),
              SizedBox(height: 16),
              _buildTimeDropdown(),
              SizedBox(height: 16),
              _buildStopageSelection(),
              SizedBox(height: 20),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  void searchInstitite() async {
    //print data
    final tspName = _instituteController.text;
    _userId = await SharedPreferenceHelper.getUserNumber();
    _sessionId = await SharedPreferenceHelper.getUserSessionId();
    //run an api to get all institutes base on _instituteController
    ApiManager()
        .post(
          'ktusertspnamesearch',
          data: {
            'tsp_name': tspName,
            'userid': _userId,
            'sessionid': _sessionId,
          },
        )
        .then((response) {
          if (response.statusCode == 200) {
            Logger().i(response.data);
            if (response.data[0]['result'] == 'ok') {
              //show list of schoolname and tsp_id
              if (!mounted) return;
              setState(() {
                _institutes = response.data[1]['data'] as List<dynamic>;
              });
              // show dialog
              _showInstituteDialog();
            } else {
              if (!mounted) return;
              setState(() {
                _institutes = [];
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${response.data[0]['message']}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        });
  }

  void _showInstituteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Institute'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _institutes!.map((institute) {
            return ListTile(
              title: Text(institute['schoolname']),
              subtitle: Text(institute['tsp_id']),
              onTap: () {
                setState(() {
                  _selectedInstitute = institute['tsp_id'];
                  _instituteController.text = institute['schoolname'];
                  //after select change the search icon to clear icon
                  _searchIcon = Icons.clear;
                  _getrouteListBytsp();
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _getrouteListBytsp() {
    ApiManager()
        .post(
          'kturoutelistbytsp',
          data: {
            'userid': _userId,
            'sessionid': _sessionId,
            'tsp_id': _selectedInstitute,
          },
        )
        .then((response) {
          if (response.statusCode == 200) {
            Logger().i(response.data);
            if (response.data[0]['result'] == 'ok') {
              callback.call(response.data);
              if (!mounted) return;
              setState(() {
                _routes.clear();
                _routes.addAll(callback.routeList);

                // Reset selections if they don't match the new route list
                List<String> availableRoutes = callback.getRouteNames();
                if (_selectedRoute != null &&
                    !availableRoutes.contains(_selectedRoute)) {
                  _selectedRoute = null;
                  _selectedRouteId = null;
                  _selectedRouteName = null;
                  _times = [];
                  _stopages = [];
                  _selectedTime = null;
                  _selectedorpId = null;
                  _selectedStopage = null;
                  _stopageId = null;
                  _vehicleId = null;
                }
              });
            }
          }
        });
  }

  void reset_all() {
    setState(() {
      _selectedRoute = null;
      _selectedRouteId = null;
      _selectedRouteName = null;
      _times = [];
      _stopages = [];
      _selectedTime = null;
      _selectedorpId = null;
      _selectedStopage = null;
      _stopageId = null;
      _vehicleId = null;
    });
  }
}
