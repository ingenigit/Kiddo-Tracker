import 'dart:convert';

import 'package:kiddo_tracker/model/routelist.dart';

class RouteSearchCallback {
  List<RouteList> routeList;
  Set<String> uniqueRouteIds;
  Map<String, List<String>> routeTimingsMap;
  int reqStatus;

  RouteSearchCallback()
    : routeList = [],
      uniqueRouteIds = {},
      routeTimingsMap = {},
      reqStatus = 0;

  void call(dynamic response) {
    if (response == null || response is! List || response.length < 2) {
      reqStatus = -1;
      return;
    }

    try {
      if (response[0]['result'] != 'ok') {
        reqStatus = -1;
        return;
      }

      var data = response[1]['data'];
      if (data is! List) {
        reqStatus = -1;
        return;
      }

      routeList.clear();
      uniqueRouteIds.clear();
      routeTimingsMap.clear();

      for (var item in data) {
        RouteList route = RouteList.fromJson(item);
        routeList.add(route);
        uniqueRouteIds.add(route.routeId);
        routeTimingsMap.putIfAbsent(route.routeId, () => []).add(route.timing);
      }

      reqStatus = 1;
    } catch (e) {
      reqStatus = -1;
      print('Error parsing route list response: $e');
    }
  }

  int getStatus() {
    return reqStatus;
  }

  List<String> getUniqueRouteNames() {
    return uniqueRouteIds.toList();
  }

  // Return a list of route names
  List<String> getRouteNames() {
    List<String> routeNames = [];
    for (String routeId in uniqueRouteIds) {
      for (RouteList route in routeList) {
        if (route.routeId == routeId) {
          String type = route.type == 1 ? "OnWard" : "Return";
          routeNames.add("${route.routeName ?? route.routeId} $type");
          break;
        }
      }
    }
    return routeNames;
  }

  Map<String, List<String>> getRouteTimingsMap() {
    return routeTimingsMap;
  }

  // Return the oprId for a given timing
  int getOprIdbyTiming(String timing) {
    for (RouteList route in routeList) {
      if (route.timing == timing) {
        return route.oprid;
      }
    }
    return 0;
  }

  // Return a list of timings for a given route
  List<String> getRouteTimings(String routeId) {
    return routeTimingsMap[routeId] ?? [];
  }

  //Return a list of stop_details for a given route
  List<String> getStopDetails(String routeId) {
    List<String> stopDetails = [];
    for (RouteList route in routeList) {
      if (route.routeId == routeId && route.stopDetails != null) {
        for (var stopDetail in route.stopDetails!) {
          stopDetails.add(
            '${stopDetail.stopName}\nArrival: ${stopDetail.arrival}\nDeparture: ${stopDetail.departure}\nLocation: ${stopDetail.location ?? ''}\n',
          );
        }
      }
    }
    return stopDetails;
  }
}
