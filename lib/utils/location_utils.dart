Map<String, dynamic> extractLocationAndRouteData(
  dynamic responseLocation,
  dynamic responseRouteDetail,
) {
  final Map<String, dynamic> map = {};

  if (responseLocation.statusCode == 200 &&
      responseRouteDetail.statusCode == 200) {
    if (responseLocation.data.isNotEmpty &&
        responseLocation.data[0]['result'] == 'ok' &&
        responseLocation.data[1]['data'].isNotEmpty &&
        responseLocation.data[1]['data'][0]['operation_status'] == 0) {
      final location = responseLocation.data[1]['data'][0]['current_location'];
      final latitude = location.split(',')[0];
      final longitude = location.split(',')[1];
      map['latitude'] = latitude;
      map['longitude'] = longitude;
    }

    if (responseRouteDetail.data.isNotEmpty &&
        responseRouteDetail.data[0]['result'] == 'ok' &&
        responseRouteDetail.data.length > 1 &&
        responseRouteDetail.data[1]['data'].isNotEmpty) {
      map['vehicle_name'] = responseRouteDetail.data[1]['data'][0]['vehicle_name'];
      map['reg_no'] = responseRouteDetail.data[1]['data'][0]['reg_no'];
      map['driver_name'] = responseRouteDetail.data[1]['data'][0]['driver_name'];
      map['contact1'] = responseRouteDetail.data[1]['data'][0]['contact1'];
      map['contact2'] = responseRouteDetail.data[1]['data'][0]['contact2'];
    }
  }
  return map;
}
