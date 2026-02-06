import 'package:equatable/equatable.dart';
import 'package:land_measure/core/models/coordinate.dart';
import 'package:land_measure/core/models/land_plot.dart';
import 'package:land_measure/core/utils/unit_converter.dart';

abstract class MeasurementState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MeasurementInitial extends MeasurementState {}

class MeasurementLoading extends MeasurementState {}

class MeasurementInProgress extends MeasurementState {
  final List<Coordinate> markers;
  final List<List<Coordinate>> undoStack;
  final List<List<Coordinate>> redoStack;
  final double? areaInSqMeters;
  final double? perimeterInMeters;
  final List<double> segmentLengths;
  final bool isGpsTracking;
  final Coordinate? currentLocation;
  final AreaUnit areaUnit;
  final LengthUnit lengthUnit;

  MeasurementInProgress({
    this.markers = const [],
    this.undoStack = const [],
    this.redoStack = const [],
    this.areaInSqMeters,
    this.perimeterInMeters,
    this.segmentLengths = const [],
    this.isGpsTracking = false,
    this.currentLocation,
    this.areaUnit = AreaUnit.squareMeters,
    this.lengthUnit = LengthUnit.meters,
  });

  bool get canUndo => undoStack.isNotEmpty;
  bool get canRedo => redoStack.isNotEmpty;
  bool get canSave => markers.length >= 3;
  int get markerCount => markers.length;

  String get formattedArea {
    if (areaInSqMeters == null) return '--';
    return UnitConverter.formatArea(areaInSqMeters!, areaUnit);
  }

  String get formattedPerimeter {
    if (perimeterInMeters == null) return '--';
    return UnitConverter.formatLength(perimeterInMeters!, lengthUnit);
  }

  MeasurementInProgress copyWith({
    List<Coordinate>? markers,
    List<List<Coordinate>>? undoStack,
    List<List<Coordinate>>? redoStack,
    double? areaInSqMeters,
    double? perimeterInMeters,
    List<double>? segmentLengths,
    bool? isGpsTracking,
    Coordinate? currentLocation,
    AreaUnit? areaUnit,
    LengthUnit? lengthUnit,
  }) {
    return MeasurementInProgress(
      markers: markers ?? this.markers,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
      areaInSqMeters: areaInSqMeters ?? this.areaInSqMeters,
      perimeterInMeters: perimeterInMeters ?? this.perimeterInMeters,
      segmentLengths: segmentLengths ?? this.segmentLengths,
      isGpsTracking: isGpsTracking ?? this.isGpsTracking,
      currentLocation: currentLocation ?? this.currentLocation,
      areaUnit: areaUnit ?? this.areaUnit,
      lengthUnit: lengthUnit ?? this.lengthUnit,
    );
  }

  @override
  List<Object?> get props => [
    markers,
    undoStack,
    redoStack,
    areaInSqMeters,
    perimeterInMeters,
    isGpsTracking,
    currentLocation,
    areaUnit,
    lengthUnit,
  ];
}

class MeasurementSaved extends MeasurementState {
  final LandPlot plot;
  MeasurementSaved(this.plot);

  @override
  List<Object?> get props => [plot];
}

class MeasurementError extends MeasurementState {
  final String message;
  MeasurementError(this.message);

  @override
  List<Object?> get props => [message];
}
