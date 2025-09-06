import 'dart:convert';

import 'package:logger/logger.dart';

class RouteList {
  final int oprid;
  final int type;
  final String routeId;
  final String timing;
  final String vehicleId;
  final List<StopDetail>? stopDetails;
  final String? routeName;
  final List<StopListItem>? stopList;

  RouteList({
    required this.oprid,
    required this.type,
    required this.routeId,
    required this.timing,
    required this.vehicleId,
    this.stopDetails,
    this.routeName,
    this.stopList,
  });

  factory RouteList.fromJson(Map<String, dynamic> json) {
    List<StopDetail>? details;
    if (json['stop_details'] != null &&
        json['stop_details'].toString().isNotEmpty) {
      try {
        String processedJson = _preprocessStopDetailsJson(
          json['stop_details'].toString(),
        );
        details = (jsonDecode(processedJson) as List)
            .map((e) => StopDetail.fromDynamic(e))
            .toList();
      } catch (e) {
        print('Error parsing stop_details: $e');
        details = null;
      }
    }

    List<StopListItem>? stopList;
    if (json['stop_list'] != null && json['stop_list'].toString().isNotEmpty) {
      try {
        stopList = (jsonDecode(json['stop_list']) as List)
            .map((e) => StopListItem.fromJson(e))
            .toList();
      } catch (_) {
        stopList = null;
      }
    }

    return RouteList(
      oprid: json['oprid'],
      type: json['type'],
      routeId: json['route_id'],
      timing: json['timing'],
      vehicleId: json['vehicle_id'],
      routeName: json['route_name'],
      stopDetails: details,
      stopList: stopList,
    );
  }

  Map<String, dynamic> toJson() => {
    'oprid': oprid,
    'type': type,
    'route_id': routeId,
    'timing': timing,
    'vehicle_id': vehicleId,
    'route_name': routeName,
    'stop_details': stopDetails?.map((e) => e.toJson()).toList(),
    'stop_list': stopList?.map((e) => e.toJson()).toList(),
  };

  static String _preprocessStopDetailsJson(String jsonString) {
    // Fix malformed JSON from server
    // Replace curly braces with square brackets for array values
    // Handle unescaped newlines and control characters

    // First, escape any unescaped newlines and control characters in strings
    String escaped = jsonString.replaceAllMapped(RegExp(r'("[^"]*")'), (match) {
      String content = match.group(1)!;
      // Replace unescaped newlines with \n
      content = content.replaceAll('\n', '\\n');
      // Replace other control characters if any
      content = content.replaceAll('\r', '\\r');
      content = content.replaceAll('\t', '\\t');
      return content;
    });

    // Replace malformed object syntax {"key":{value1,value2}} with {"key":[value1,value2]}
    escaped = escaped.replaceAllMapped(RegExp(r'\{([^:]+):\{([^}]+)\}\}'), (
      match,
    ) {
      String key = match.group(1)!;
      String values = match.group(2)!;
      Logger().i('key: $key, values: $values');
      return '{"$key":[$values]}';
    });

    return escaped;
  }
}

class StopDetail {
  final String id;
  final String stopName;
  final String arrival;
  final String departure;
  final String? location;

  StopDetail({
    required this.id,
    required this.stopName,
    required this.arrival,
    required this.departure,
    this.location,
  });

  factory StopDetail.fromDynamic(dynamic data) {
    print('StopDetail data: $data');
    if (data is Map<String, dynamic> && data.isNotEmpty) {
      final key = data.keys.first;
      final values = data[key];
      print('StopDetail values: $values, length: ${values?.length}');
      if (values is List && (values.length == 3 || values.length == 4)) {
        return StopDetail(
          id: key,
          stopName: values[0].toString().trim(),
          arrival: values[1],
          departure: values[2],
          location: values.length > 3 ? values[3] : null,
        );
      }
    }
    throw Exception('Invalid stop detail data: $data');
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'stop_name': stopName,
    'arrival': arrival,
    'departure': departure,
    'location': location,
  };
}

class StopListItem {
  final String stopId;
  final String stopName;
  final String location;
  final int stopType;

  StopListItem({
    required this.stopId,
    required this.stopName,
    required this.location,
    required this.stopType,
  });

  factory StopListItem.fromJson(Map<String, dynamic> json) {
    return StopListItem(
      stopId: json['stop_id'],
      stopName: json['stop_name'],
      location: json['location'],
      stopType: json['stop_type'],
    );
  }

  Map<String, dynamic> toJson() => {
    'stop_id': stopId,
    'stop_name': stopName,
    'location': location,
    'stop_type': stopType,
  };
}
