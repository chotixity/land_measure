import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:land_measure/core/theme/app_theme.dart';
import 'package:land_measure/features/measurement/presentation/bloc/measurement_bloc.dart';
import 'package:land_measure/features/measurement/presentation/bloc/measurement_event.dart';
import 'package:land_measure/features/measurement/presentation/bloc/measurement_state.dart';

class GoogleMapsView extends StatefulWidget {
  const GoogleMapsView({super.key});

  @override
  State<GoogleMapsView> createState() => _GoogleMapsViewState();
}

class _GoogleMapsViewState extends State<GoogleMapsView> {
  GoogleMapController? _controller;
  bool _hasMovedToLocation = false;

  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(0, 0),
    zoom: 2,
  );

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _moveToLocation(LatLng position) {
    _controller?.animateCamera(CameraUpdate.newLatLngZoom(position, 17));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MeasurementBloc, MeasurementState>(
      listenWhen: (previous, current) {
        if (_hasMovedToLocation) return false;
        return current is MeasurementInProgress &&
            current.currentLocation != null;
      },
      listener: (context, state) {
        if (state is MeasurementInProgress && state.currentLocation != null) {
          _hasMovedToLocation = true;
          _moveToLocation(state.currentLocation!.toLatLng());
        }
      },
      builder: (context, state) {
        final markers = <Marker>{};
        final polygons = <Polygon>{};
        final polylines = <Polyline>{};

        if (state is MeasurementInProgress && state.markers.isNotEmpty) {
          final points =
              state.markers.map((c) => c.toLatLng()).toList();

          if (state.isGpsTracking) {
            // ── Tracking mode: show walked path as a live polyline ──────────
            // Pin the start point so the user knows where they began
            markers.add(
              Marker(
                markerId: const MarkerId('start'),
                position: points.first,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen,
                ),
                infoWindow: const InfoWindow(title: 'Start'),
              ),
            );
            polylines.add(
              Polyline(
                polylineId: const PolylineId('tracked_path'),
                points: points,
                color: AppColors.neonGreen,
                width: 3,
                jointType: JointType.round,
                endCap: Cap.roundCap,
                startCap: Cap.roundCap,
              ),
            );
          } else {
            // ── Done mode: show closed polygon (measured area) ───────────────
            if (points.length >= 3) {
              polygons.add(
                Polygon(
                  polygonId: const PolygonId('measurement_area'),
                  points: points,
                  strokeColor: AppColors.neonGreen,
                  strokeWidth: 2,
                  fillColor: AppColors.neonGreen.withAlpha(45),
                ),
              );
            } else {
              // Fewer than 3 points — just show the connecting line
              polylines.add(
                Polyline(
                  polylineId: const PolylineId('measurement_line'),
                  points: points,
                  color: AppColors.primaryGreen,
                  width: 2,
                ),
              );
              for (int i = 0; i < points.length; i++) {
                markers.add(
                  Marker(
                    markerId: MarkerId('marker_$i'),
                    position: points[i],
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen,
                    ),
                  ),
                );
              }
            }
          }
        }

        return GoogleMap(
          initialCameraPosition: _defaultPosition,
          onMapCreated: (controller) {
            _controller = controller;
            if (!_hasMovedToLocation &&
                state is MeasurementInProgress &&
                state.currentLocation != null) {
              _hasMovedToLocation = true;
              _moveToLocation(state.currentLocation!.toLatLng());
            }
          },
          // Tap to add manual pins only when NOT recording
          onTap: state is MeasurementInProgress && !state.isGpsTracking
              ? (position) =>
                  context.read<MeasurementBloc>().add(AddMarkerEvent(position))
              : null,
          markers: markers,
          polygons: polygons,
          polylines: polylines,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          mapType: MapType.satellite,
          zoomControlsEnabled: false,
          compassEnabled: true,
        );
      },
    );
  }
}
