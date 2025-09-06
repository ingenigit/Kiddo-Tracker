import 'package:flutter/material.dart';
import 'package:kiddo_tracker/api/apimanage.dart';
import 'package:kiddo_tracker/api/route_search_callback.dart';
import 'package:kiddo_tracker/model/routelist.dart';
import 'package:kiddo_tracker/widget/shareperference.dart';
import 'package:logger/logger.dart';

class AddChildRoutePage extends StatefulWidget {
  String? nickName;
  AddChildRoutePage({super.key, this.nickName});
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
  String? _selectedRouteId;
  String? _selectedTime;
  String? _selectedorpId;
  String? _selectedStopage;
  String? _stopageId;
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
      Logger().i('Institute: $_selectedInstitute');
      Logger().i('Route: $_selectedRouteId');
      Logger().i('Time: $_selectedorpId');
      Logger().i('Stopage ID: $_stopageId');
      // Add backend logic here
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fix the errors in red')));
    }
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
              TextFormField(
                controller: _instituteController,
                decoration: InputDecoration(
                  labelText: 'Institute',
                  //make icon clickable
                  suffixIcon: IconButton(
                    icon: Icon(_searchIcon),
                    onPressed: () {
                      //run search function
                      searchInstitite();
                    },
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter institute' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Route No',
                  border: OutlineInputBorder(),
                ),
                value: _selectedRoute,
                items: callback
                    .getRouteNames()
                    .map(
                      (route) => DropdownMenuItem<String>(
                        value: route,
                        child: Text(route),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRoute = value;
                    if (value != null) {
                      try {
                        // Find the RouteList that matches the selected display string
                        var selectedRoute = _routes.firstWhere((r) {
                          String display =
                              "${r.routeName ?? r.routeId} ${r.type == 1 ? "OnWard" : "Return"}";
                          return display == value;
                        });
                        Logger().i(selectedRoute.toJson());
                        _selectedRouteId = selectedRoute.routeId;
                        _times = callback.getRouteTimings(_selectedRouteId!);
                        // _stopages = callback.getStopDetails(_selectedRouteId!);
                        _stopages = (selectedRoute.stopDetails ?? []).map((
                          stop,
                        ) {
                          return {
                            'key': stop.id,
                            'value':
                                '${stop.stopName} (${stop.arrival} - ${stop.departure})',
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
                  });
                },
                validator: (value) => value == null ? 'Select a route' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Time',
                  border: OutlineInputBorder(),
                ),
                value: _selectedTime,
                items: _times
                    .map(
                      (time) =>
                          DropdownMenuItem(value: time, child: Text(time)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTime = value;
                    _selectedorpId = callback
                        .getOprIdbyTiming(value!)
                        .toString();
                  });
                },
                validator: (value) => value == null ? 'Select a time' : null,
              ),
              SizedBox(height: 16),
              Text(
                'Select Stopage:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._stopages.map(
                (stopage) => RadioListTile<String>(
                  title: Text(stopage['value']!),
                  value: stopage['value']!,
                  groupValue: _selectedStopage,
                  onChanged: (value) {
                    setState(() {
                      _selectedStopage = value;
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_selectedStopage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please select a stopage')),
                    );
                    return;
                  }
                  _submit();
                },
                child: Text('Add Route'),
              ),
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
                  _times = [];
                  _stopages = [];
                  _selectedTime = null;
                  _selectedorpId = null;
                  _selectedStopage = null;
                  _stopageId = null;
                }
              });
            }
          }
        });
  }
}
