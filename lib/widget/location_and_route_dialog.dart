import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationAndRouteDialog extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String vehicleName;
  final String regNo;
  final String driverName;
  final String contact1;
  final String contact2;

  const LocationAndRouteDialog({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.vehicleName,
    required this.regNo,
    required this.driverName,
    required this.contact1,
    required this.contact2,
  }) : super(key: key);

  Future<void> _callNumber(String number) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: number,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // Could not launch the dialer
      debugPrint('Could not launch dialer for $number');
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLng position = LatLng(latitude, longitude);

    return AlertDialog(
      title: const Text('Vehicle Location & Details'),
      content: SizedBox(
        width: 350,
        height: 450,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 250,
              width: double.infinity,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: position,
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('vehicle_location'),
                    position: position,
                  ),
                },
                zoomControlsEnabled: true,
                myLocationButtonEnabled: false,
                mapType: MapType.normal,
              ),
            ),
            const SizedBox(height: 12),
            Text('Vehicle Name: $vehicleName'),
            Text('Registration No: $regNo'),
            Text('Driver Name: $driverName'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _callNumber(contact1),
                    icon: const Icon(Icons.call),
                    label: Text(contact1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _callNumber(contact2),
                    icon: const Icon(Icons.call),
                    label: Text(contact2),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
