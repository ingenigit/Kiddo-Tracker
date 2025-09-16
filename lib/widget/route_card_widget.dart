import 'package:flutter/material.dart';
import 'package:kiddo_tracker/model/route.dart';
import 'package:kiddo_tracker/widget/sqflitehelper.dart';

class RouteCardWidget extends StatefulWidget {
  final String childId;
  final String routeId;
  final List<RouteInfo> routes;
  final Function(String routeId, List<RouteInfo> routes)? onBusTap;
  final Function(String routeId, List<RouteInfo> routes)? onLocationTap;
  final Function(String routeId, List<RouteInfo> routes)? onDeleteTap;
  final Map<String, bool> activeRoutes;
  final int boardRefreshKey;

  const RouteCardWidget({
    super.key,
    required this.childId,
    required this.routeId,
    required this.routes,
    required this.onBusTap,
    required this.onLocationTap,
    required this.onDeleteTap,
    required this.activeRoutes,
    required this.boardRefreshKey,
  });

  @override
  State<RouteCardWidget> createState() => _RouteCardWidgetState();
}

class _RouteCardWidgetState extends State<RouteCardWidget> {
  String onboardTime = '_';
  String offboardTime = '_';
  final SqfliteHelper _sqfliteHelper = SqfliteHelper();

  @override
  void initState() {
    super.initState();
    _fetchActivityTimes();
  }

  @override
  void didUpdateWidget(covariant RouteCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.boardRefreshKey != widget.boardRefreshKey) {
      _fetchActivityTimes();
    }
  }

  Future<void> _fetchActivityTimes() async {
    if (widget.routes.isNotEmpty) {
      final route = widget.routes.first;
      //get current date onboard time and offboard time
      //also upadate onboard time and offboard time if same student message is received
      final times = await _sqfliteHelper.getActivityTimesForRoute(
        route.routeId,
        route.oprId,
        widget.childId,
      );
      setState(() {
        onboardTime = times['onboardTime'] ?? '_';
        offboardTime = times['offboardTime'] ?? '_';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Find earliest stopArrivalTime for route start time
    String startTime = '';
    if (widget.routes.isNotEmpty) {
      widget.routes.sort(
        (a, b) => a.stopArrivalTime.compareTo(b.stopArrivalTime),
      );
      startTime = widget.routes.first.stopArrivalTime;
    }

    // return Card(
    //   margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    //   elevation: 4,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(12),
    //   ),
    //   child: Padding(
    //     padding: const EdgeInsets.all(16.0),
    //     child: Row(
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       children: [
    //         Expanded(
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Row(
    //                 children: [
    //                   Expanded(
    //                     child: Text(
    //                       '${widget.routes.first.routeName} starts at $startTime',
    //                       style: const TextStyle(
    //                         fontSize: 16,
    //                         fontWeight: FontWeight.bold,
    //                         fontFamily: 'Poppins',
    //                         color: Colors.black87,
    //                       ),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //               const SizedBox(height: 12),
    //               InkWell(
    //                 onTap: widget.onOnboardTap != null
    //                     ? () {
    //                         print('Onboard tapped for route ${widget.routeId}');
    //                         widget.onOnboardTap!(
    //                           widget.routeId,
    //                           widget.routes,
    //                         );
    //                       }
    //                     : null,
    //                 borderRadius: BorderRadius.circular(8),
    //                 child: Padding(
    //                   padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    //                   child: Row(
    //                     children: [
    //                       Icon(
    //                         Icons.login,
    //                         size: 18,
    //                         color: Colors.blue,
    //                       ),
    //                       const SizedBox(width: 8),
    //                       Text(
    //                         'Onboard at $onboardTime',
    //                         style: const TextStyle(
    //                           color: Colors.blue,
    //                           fontSize: 14,
    //                           fontFamily: 'Poppins',
    //                           fontWeight: FontWeight.w500,
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //               const SizedBox(height: 8),
    //               InkWell(
    //                 onTap: widget.onOffboardTap != null
    //                     ? () {
    //                         print('Offboard tapped for route ${widget.routeId}');
    //                         widget.onOffboardTap!(
    //                           widget.routeId,
    //                           widget.routes,
    //                         );
    //                       }
    //                     : null,
    //                 borderRadius: BorderRadius.circular(8),
    //                 child: Padding(
    //                   padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    //                   child: Row(
    //                     children: [
    //                       Icon(
    //                         Icons.logout,
    //                         size: 18,
    //                         color: Colors.blue,
    //                       ),
    //                       const SizedBox(width: 8),
    //                       Text(
    //                         'Offboard at $offboardTime',
    //                         style: const TextStyle(
    //                           color: Colors.blue,
    //                           fontSize: 14,
    //                           fontFamily: 'Poppins',
    //                           fontWeight: FontWeight.w500,
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //         const SizedBox(width: 16),
    //         Column(
    //           children: [
    //             InkWell(
    //               onTap: _getBusIconColor() == Colors.green && widget.onBusTap != null
    //                   ? () => widget.onBusTap!(widget.routeId, widget.routes)
    //                   : null,
    //               borderRadius: BorderRadius.circular(8),
    //               child: Container(
    //                 padding: const EdgeInsets.all(8),
    //                 decoration: BoxDecoration(
    //                   color: _getBusIconColor().withOpacity(0.1),
    //                   borderRadius: BorderRadius.circular(8),
    //                 ),
    //                 child: Icon(
    //                   Icons.directions_bus_outlined,
    //                   size: 36,
    //                   color: _getBusIconColor(),
    //                 ),
    //               ),
    //             ),
    //             const SizedBox(height: 12),
    //             Row(
    //               children: [
    //                 Icon(Icons.location_on, size: 20, color: Colors.grey),
    //                 const SizedBox(width: 8),
    //                 InkWell(
    //                   onTap: widget.onDeleteTap != null
    //                       ? () => widget.onDeleteTap!(
    //                           widget.routeId,
    //                           widget.routes,
    //                         )
    //                       : null,
    //                   borderRadius: BorderRadius.circular(8),
    //                   child: Container(
    //                     padding: const EdgeInsets.all(4),
    //                     decoration: BoxDecoration(
    //                       color: Colors.red.withOpacity(0.1),
    //                       borderRadius: BorderRadius.circular(8),
    //                     ),
    //                     child: const Icon(
    //                       Icons.delete,
    //                       size: 20,
    //                       color: Colors.red,
    //                     ),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ],
    //         ),
    //       ],
    //     ),
    //   ),
    // );
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap:
                            _getBusIconColor() == Colors.green &&
                                widget.onBusTap != null
                            ? () => widget.onBusTap!(
                                widget.routeId,
                                widget.routes,
                              )
                            : null,
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: _getBusIconColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Icon(
                            Icons.directions_bus_outlined,
                            size: 15,
                            color: _getBusIconColor(),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${widget.routes.first.routeName} starts at $startTime',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.login, size: 18, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Onboard at $onboardTime',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.logout,
                            size: 18,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Offboard at $offboardTime',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              children: [
                InkWell(
                  onTap: widget.onLocationTap != null
                      ? () =>
                            widget.onLocationTap!(widget.routeId, widget.routes)
                      : null,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.share_location_outlined,
                      size: 30,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                InkWell(
                  onTap: widget.onDeleteTap != null
                      ? () => widget.onDeleteTap!(widget.routeId, widget.routes)
                      : null,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete,
                      size: 30,
                      color: Color.fromARGB(255, 255, 136, 127),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getBusIconColor() {
    // Check if any route in the list is active
    for (var route in widget.routes) {
      String key = '${route.routeId}_${route.oprId}';
      if (widget.activeRoutes[key] == true) {
        return Colors.green; // Active
      }
    }
    return Colors.red; // Inactive or default
  }
}
