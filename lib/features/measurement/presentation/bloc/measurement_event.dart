import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:land_measure/core/models/coordinate.dart';
import 'package:land_measure/core/utils/unit_converter.dart';

abstract class MeasurementEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class Initializemeasurement extends MeasurementEvent {}

class StartGpsTracking extends MeasurementEvent {}

class StopGpsTracking extends MeasurementEvent {}

class AddMarkerEvent extends MeasurementEvent {
  final LatLng position;
  AddMarkerEvent(this.position);
  @override
  List<Object?> get props => [position];
}

class UpdateMarkerEvent extends MeasurementEvent {
  final int index;
  final LatLng newPosition;
  UpdateMarkerEvent(this.index, this.newPosition);
  @override
  List<Object?> get props => [index, newPosition];
}

class RemoveLastMarkerEvent extends MeasurementEvent {}

class ClearAllMarkersEvent extends MeasurementEvent {}

class UndoLastAction extends MeasurementEvent {}

class RedoLastEvent extends MeasurementEvent {}

class ChangeAreaUnit extends MeasurementEvent {
  final AreaUnit unit;
  ChangeAreaUnit(this.unit);
  @override
  List<Object?> get props => [unit];
}

class ChangeLengthUnit extends MeasurementEvent {
  final LengthUnit unit;
  ChangeLengthUnit(this.unit);
  @override
  List<Object?> get props => [unit];
}

class SavePlotEvent extends MeasurementEvent {
  final String name;
  final String? notes;
  SavePlotEvent(this.name, {this.notes});

  @override
  List<Object?> get props => [name, notes];
}

class LocationUpdated extends MeasurementEvent {
  final Coordinate location;
  LocationUpdated(this.location);

  @override
  List<Object?> get props => [location];
}
