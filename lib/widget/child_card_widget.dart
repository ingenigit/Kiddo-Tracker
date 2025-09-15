import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kiddo_tracker/model/child.dart';
import 'package:kiddo_tracker/model/subscribe.dart';
import 'package:kiddo_tracker/widget/route_card_widget.dart';
import 'package:kiddo_tracker/model/route.dart';
import 'package:logger/logger.dart';

class ChildCardWidget extends StatelessWidget {
  final Child child;
  final SubscriptionPlan? subscription;
  final VoidCallback? onSubscribeTap;
  final VoidCallback? onAddRouteTap;
  final Function(String routeId, List<RouteInfo> routes)? onBusTap;
  final Function(String routeId, List<RouteInfo> routes)? onLocationTap;
  final Function(String routeId, List<RouteInfo> routes)? onDeleteTap;
  final Map<String, bool> activeRoutes;
  final int boardRefreshKey;

  const ChildCardWidget({
    super.key,
    required this.child,
    this.subscription,
    this.onSubscribeTap,
    this.onAddRouteTap,
    required this.onBusTap,
    required this.onLocationTap,
    required this.onDeleteTap,
    required this.activeRoutes,
    required this.boardRefreshKey,
  });

  String _statusText(int status) {
    switch (status) {
      case 1:
        return 'Onboard';
      case 2:
        return 'Offboard';
      default:
        return 'Offboard';
    }
  }

  Map<String, List<RouteInfo>> _groupRoutesByRouteId(List<RouteInfo> routes) {
    Map<String, List<RouteInfo>> grouped = {};
    for (var route in routes) {
      if (!grouped.containsKey(route.routeId)) {
        grouped[route.routeId] = [];
      }
      grouped[route.routeId]!.add(route);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedRoutes = _groupRoutesByRouteId(child.routeInfo);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Name, status, location icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  child.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: 'Poppins',
                  ),
                ),
                Row(
                  children: [
                    Builder(
                      builder: (context) {
                        if (subscription == null) {
                          return GestureDetector(
                            onTap: onSubscribeTap,
                            child: const Text(
                              "Subscribe",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          );
                        } else {
                          bool isExpired = DateTime.parse(
                            subscription!.enddate,
                          ).isBefore(DateTime.now());
                          Logger().i(isExpired);
                          if (subscription!.student_id != child.studentId) {
                            return GestureDetector(
                              onTap: onSubscribeTap,
                              child: const Text(
                                "Subscribess",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            );
                          } else if (isExpired) {
                            return GestureDetector(
                              onTap: onSubscribeTap,
                              child: const Text(
                                "Add New Plan",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            );
                          } else if (subscription!.student_id == child.studentId && child.status == 0) {
                            return GestureDetector(
                              child: const Text(
                                "Plan Selected",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            );
                          }
                          else {
                            return Text(
                              _statusText(child.onboard_status),
                              style: TextStyle(
                                color: child.onboard_status == 1
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Unit info
            Text(
              child.school,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            // Route cards
            Column(
              children: groupedRoutes.entries.map((entry) {
                final routeId = entry.key;
                final routes = entry.value;
                return RouteCardWidget(
                  childId: child.studentId,
                  routeId: routeId,
                  routes: routes,
                  onBusTap: onBusTap,
                  onLocationTap: onLocationTap,
                  onDeleteTap: onDeleteTap,
                  activeRoutes: activeRoutes,
                  boardRefreshKey: boardRefreshKey,
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            // Add Route button
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: onAddRouteTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Add Route',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 600.ms).slide(begin: const Offset(0, 0.1));
  }
}
