// lib/core/utils/geo_calculator.dart

import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:land_measure/core/models/coordinate.dart';

class GeoCalculator {
  static const double earthRadius = 6371000; // meters

  /// Calculate area using Spherical Excess Formula
  /// Accurate for polygons on Earth's surface
  static double calculateAreaFromCoordinates(List<Coordinate> coordinates) {
    return calculateArea(coordinates.map((c) => c.toLatLng()).toList());
  }

  static double calculateArea(List<LatLng> points) {
    if (points.length < 3) return 0;

    double total = 0;
    int n = points.length;

    for (int i = 0; i < n; i++) {
      int j = (i + 1) % n;
      int k = (i + 2) % n;

      total += _toRadians(points[j].longitude) *
          (sin(_toRadians(points[k].latitude)) -
              sin(_toRadians(points[i].latitude)));
    }

    double sphericalExcess = total.abs() / 2;
    return sphericalExcess * earthRadius * earthRadius;
  }

  /// Calculate perimeter (total boundary length)
  static double calculatePerimeterFromCoordinates(List<Coordinate> coordinates) {
    return calculatePerimeter(coordinates.map((c) => c.toLatLng()).toList());
  }

  static double calculatePerimeter(List<LatLng> points) {
    if (points.length < 2) return 0;

    double total = 0;
    for (int i = 0; i < points.length; i++) {
      int next = (i + 1) % points.length;
      total += haversineDistance(points[i], points[next]);
    }
    return total;
  }

  /// Get individual segment lengths
  static List<double> getSegmentLengths(List<LatLng> points) {
    if (points.length < 2) return [];

    List<double> segments = [];
    for (int i = 0; i < points.length; i++) {
      int next = (i + 1) % points.length;
      segments.add(haversineDistance(points[i], points[next]));
    }
    return segments;
  }

  /// Haversine formula for distance between two points
  static double haversineDistance(LatLng a, LatLng b) {
    double dLat = _toRadians(b.latitude - a.latitude);
    double dLon = _toRadians(b.longitude - a.longitude);

    double aCalc = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(a.latitude)) *
            cos(_toRadians(b.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(aCalc), sqrt(1 - aCalc));
    return earthRadius * c;
  }

  static double _toRadians(double degree) => degree * pi / 180;
}