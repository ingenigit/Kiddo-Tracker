import 'dart:convert';

class Stopage {
  final int oprid;
  final int type;
  final String routeId;
  final String timing;
  final String vehicleId;
  final String? routeName;
  final List<StopDetail>? stopDetails;
  final List<StopListItem>? stopList;

  Stopage({
    required this.oprid,
    required this.type,
    required this.routeId,
    required this.timing,
    required this.vehicleId,
    this.routeName,
    this.stopDetails,
    this.stopList,
  });

  factory Stopage.fromJson(Map<String, dynamic> json) {
    List<StopDetail>? details;
    if (json['stop_details'] != null && json['stop_details'].toString().isNotEmpty) {
      try {
        details = (jsonDecode(json['stop_details']) as List)
            .map((e) => StopDetail.fromDynamic(e))
            .toList();
      } catch (_) {
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

    return Stopage(
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
}

class StopDetail {
  final String id;
  final String name;
  final String arrival;
  final String departure;
  final String? location;

  StopDetail({
    required this.id,
    required this.name,
    required this.arrival,
    required this.departure,
    this.location,
  });

  // Handles both formats: {"7":{"Baramunda","08:05","08:07"}} and {"1":["Khandagiri", "10:00", "10:05", "20.2568819,85.7791854"]}
  factory StopDetail.fromDynamic(dynamic data) {
    if (data is Map<String, dynamic>) {
      final key = data.keys.first;
      final value = data[key];
      if (value is List) {
        return StopDetail(
          id: key,
          name: value[0].toString().trim(),
          arrival: value[1].toString(),
          departure: value[2].toString(),
          location: value.length > 3 ? value[3].toString() : null,
        );
      } else if (value is Map) {
        final vals = value.values.toList();
        return StopDetail(
          id: key,
          name: vals[0].toString().trim(),
          arrival: vals[1].toString(),
          departure: vals[2].toString(),
        );
      }
    }
    throw FormatException('Invalid stop detail format');
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
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
}