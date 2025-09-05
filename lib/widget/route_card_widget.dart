import 'package:flutter/material.dart';
import 'package:kiddo_tracker/model/route.dart';

class RouteCardWidget extends StatelessWidget {
  final String routeId;
  final List<RouteInfo> routes;
  final Function(String routeId, List<RouteInfo> routes)? onOnboardTap;
  final Function(String routeId, List<RouteInfo> routes)? onOffboardTap;

  const RouteCardWidget({
    super.key,
    required this.routeId,
    required this.routes,
    this.onOnboardTap,
    this.onOffboardTap,
  });

  @override
  Widget build(BuildContext context) {
    // Find earliest stopArrivalTime for route start time
    String startTime = '';
    if (routes.isNotEmpty) {
      routes.sort((a, b) => a.stopArrivalTime.compareTo(b.stopArrivalTime));
      startTime = routes.first.stopArrivalTime;
    }

    // Find onboard and offboard stops
    String onboardTime = '_';
    String offboardTime = '_';
    for (var r in routes) {
      if (r.stopName.toLowerCase().contains('onboard')) {
        onboardTime = r.stopArrivalTime;
      } else if (r.stopName.toLowerCase().contains('offboard')) {
        offboardTime = r.stopArrivalTime;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${routes.first.routeName} starts at $startTime',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: onOnboardTap != null ? () => onOnboardTap!(routeId, routes) : null,
                    child: Text(
                      'Onboard at $onboardTime',
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onOffboardTap != null ? () => onOffboardTap!(routeId, routes) : null,
                    child: Text(
                      'Offboard at $offboardTime',
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.directions_bus_outlined,
              size: 30,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
