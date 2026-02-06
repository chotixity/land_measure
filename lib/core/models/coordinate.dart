import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Coordinate  extends Equatable{
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? accuracy;
  final DateTime timestamp;


  const Coordinate({required this.latitude, required this.longitude,this.altitude, this.accuracy, required this.timestamp,});

  LatLng toLatLng() => 
    LatLng(latitude, longitude);
  
  factory Coordinate.fromLatLng(LatLng latLng) {
    return Coordinate(
      latitude: latLng.latitude,
      longitude: latLng.longitude,
      timestamp: DateTime.now(),
    );
  }


  @override
  List<Object?> get props => [latitude, longitude, altitude, accuracy, timestamp];
}
