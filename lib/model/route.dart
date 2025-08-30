class RouteInfo {
  final String routeId;
  final String routeName;
  final String oprid;
  final String vehicleId;
  final String stopId;
  final String stopName;
  final String stopArrivalTime;

  RouteInfo({
    required this.routeId,
    required this.routeName,
    required this.oprid,
    required this.vehicleId,
    required this.stopId,
    required this.stopName,
    required this.stopArrivalTime,
  });

  factory RouteInfo.fromJson(Map<String, dynamic> json) {
    return RouteInfo(
      routeId: json['route_id'] ?? '',
      routeName: json['route_name'] ?? '',
      oprid: json['oprid'] ?? '',
      vehicleId: json['vehicle_id'] ?? '',
      stopId: json['stop_id'] ?? '',
      stopName: json['stop_name'] ?? '',
      stopArrivalTime: json['stop_arrival_time'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'route_id': routeId,
      'route_name': routeName,
      'oprid': oprid,
      'vehicle_id': vehicleId,
      'stop_id': stopId,
      'stop_name': stopName,
      'stop_arrival_time': stopArrivalTime,
    };
  }
}