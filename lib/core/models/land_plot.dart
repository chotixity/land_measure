import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'coordinate.dart';

class LandPlot extends Equatable {
  final String id;
  final String name;
  final List<Coordinate> coordinates;
  final double areaInSquareMeters;
  final double perimeterInMeters;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? notes;
  final List<String>? photoUrls;

  const LandPlot({
    required this.id,
    required this.name,
    required this.coordinates,
    required this.areaInSquareMeters,
    required this.perimeterInMeters,
    required this.createdAt,
    this.updatedAt,
    this.notes,
    this.photoUrls,
  });

  /// Get coordinates as Google Maps polygon points
  List<LatLng> get polygonPoints => 
      coordinates.map((c) => c.toLatLng()).toList();

  /// Get center point for camera positioning
  LatLng get center {
    if (coordinates.isEmpty) return const LatLng(0, 0);
    
    double latSum = 0, lngSum = 0;
    for (final coord in coordinates) {
      latSum += coord.latitude;
      lngSum += coord.longitude;
    }
    return LatLng(latSum / coordinates.length, lngSum / coordinates.length);
  }

  /// Get bounds for camera fit
  LatLngBounds get bounds {
    double minLat = coordinates.first.latitude;
    double maxLat = coordinates.first.latitude;
    double minLng = coordinates.first.longitude;
    double maxLng = coordinates.first.longitude;

    for (final coord in coordinates) {
      minLat = coord.latitude < minLat ? coord.latitude : minLat;
      maxLat = coord.latitude > maxLat ? coord.latitude : maxLat;
      minLng = coord.longitude < minLng ? coord.longitude : minLng;
      maxLng = coord.longitude > maxLng ? coord.longitude : maxLng;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  List<Object?> get props => [id, name, coordinates, areaInSquareMeters];
}