import 'package:geolocator/geolocator.dart';

Future<bool> isWithinRange(
  String reference,
  String target,
  double range,
) async {
  // separate latitude and longitude from the reference string
  final refParts = reference.split(',');
  if (refParts.length != 2) return false; // Invalid reference format

  final referenceLat = double.tryParse(refParts[0].trim());
  final referenceLon = double.tryParse(refParts[1].trim());

  // separate latitude and longitude from the target string
  final targetParts = target.split(',');
  if (targetParts.length != 2) return false; // Invalid target format

  final targetLat = double.tryParse(targetParts[0].trim());
  final targetLon = double.tryParse(targetParts[1].trim());

  if (referenceLat == null ||
      referenceLon == null ||
      targetLat == null ||
      targetLon == null) {
    return false; // Invalid latitude or longitude values
  }

  // Get distance between two locations and compare directly
  return Geolocator.distanceBetween(
        referenceLat,
        referenceLon,
        targetLat,
        targetLon,
      ) <=
      range;
}
