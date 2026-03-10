import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:land_measure/core/models/coordinate.dart';
import 'package:land_measure/core/utils/geo_calculator.dart';
import 'package:land_measure/features/measurement/domain/usecases/save_plot_use_case.dart';
import 'package:land_measure/features/measurement/presentation/bloc/measurement_event.dart';
import 'package:land_measure/features/measurement/presentation/bloc/measurement_state.dart';
import 'package:land_measure/shared/services/location_service.dart';

class MeasurementBloc extends Bloc<MeasurementEvent, MeasurementState> {
  final LocationService _locationService;
  final SavePlotUseCase _savePlotUseCase;
  StreamSubscription<Coordinate>? _locationSubscription;

  MeasurementBloc({
    required LocationService locationService,
    required SavePlotUseCase savePlotUseCase,
  }) : _locationService = locationService,
       _savePlotUseCase = savePlotUseCase,
       super(MeasurementInitial()) {
    on<Initializemeasurement>(_onInitializeMeasurement);
    on<StartGpsTracking>(_onStartGpsTracking);
    on<StopGpsTracking>(_onStopGpsTracking);
    on<AddMarkerEvent>(_onAddMarker);
    on<UpdateMarkerEvent>(_onUpdateMarker);
    on<RemoveLastMarkerEvent>(_onRemoveLastMarker);
    on<ClearAllMarkersEvent>(_onClearAllMarkers);
    on<UndoLastAction>(_onUndo);
    on<RedoLastEvent>(_onRedo);
    on<ChangeAreaUnit>(_onChangeAreaUnit);
    on<ChangeLengthUnit>(_onChangeLengthUnit);
    on<SavePlotEvent>(_onSavePlot);
    on<LocationUpdated>(_onLocationUpdated);
  }

  Future<void> _onInitializeMeasurement(
    Initializemeasurement event,
    Emitter<MeasurementState> emit,
  ) async {
    emit(MeasurementInProgress());

    try {
      final location = await _locationService.getCurrentLocation();
      emit(
        (state as MeasurementInProgress).copyWith(
          currentLocation: location,
        ),
      );
    } catch (e) {
      // Location not available, continue without it
    }
  }

  Future<void> _onStartGpsTracking(
    StartGpsTracking event,
    Emitter<MeasurementState> emit,
  ) async {
    if (state is! MeasurementInProgress) return;

    emit((state as MeasurementInProgress).copyWith(isGpsTracking: true));

    _locationSubscription = _locationService.getLocationStream().listen(
      (location) => add(LocationUpdated(location)),
    );
  }

  void _onStopGpsTracking(
    StopGpsTracking event,
    Emitter<MeasurementState> emit,
  ) {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    emit(
      (state as MeasurementInProgress).copyWith(isGpsTracking: false),
    );
  }

  void _onAddMarker(
    AddMarkerEvent event,
    Emitter<MeasurementState> emit,
  ) {
    if (state is! MeasurementInProgress) return;
    final currentState = state as MeasurementInProgress;

    final newCoord = Coordinate.fromLatLng(event.position);

    final newMarkers = [...currentState.markers, newCoord];

    final newUndoStack = [...currentState.undoStack, currentState.markers];

    emit(
      _calculateAndEmit(
        currentState.copyWith(
          markers: newMarkers,
          undoStack: newUndoStack,
          redoStack: [],
        ),
      ),
    );
  }

  void _onUpdateMarker(
    UpdateMarkerEvent event,
    Emitter<MeasurementState> emit,
  ) {
    if (state is! MeasurementInProgress) return;
    final currentState = state as MeasurementInProgress;

    if (event.index >= currentState.markers.length) return;

    final newCoord = Coordinate.fromLatLng(event.newPosition);

    final newMarkers = List<Coordinate>.from(currentState.markers);
    newMarkers[event.index] = newCoord;

    final newUndoStack = [...currentState.undoStack, currentState.markers];

    emit(
      _calculateAndEmit(
        currentState.copyWith(
          markers: newMarkers,
          undoStack: newUndoStack,
          redoStack: [],
        ),
      ),
    );
  }

  void _onRemoveLastMarker(
    RemoveLastMarkerEvent event,
    Emitter<MeasurementState> emit,
  ) {
    if (state is! MeasurementInProgress) return;
    final currentState = state as MeasurementInProgress;
    if (currentState.markers.isEmpty) return;

    final markers = currentState.markers.sublist(
      0,
      currentState.markers.length - 1,
    );
    final undoStack = [...currentState.undoStack, currentState.markers];

    emit(
      _calculateAndEmit(
        currentState.copyWith(
          markers: markers,
          undoStack: undoStack,
          redoStack: [],
        ),
      ),
    );
  }

  void _onClearAllMarkers(
    ClearAllMarkersEvent event,
    Emitter<MeasurementState> emit,
  ) {
    if (state is! MeasurementInProgress) return;

    final currentState = state as MeasurementInProgress;

    final newUndoStack = [...currentState.undoStack, currentState.markers];

    emit(
      _calculateAndEmit(
        currentState.copyWith(
          markers: [],
          undoStack: newUndoStack,
          redoStack: [],
          areaInSqMeters: null,
          perimeterInMeters: null,
          segmentLengths: [],
        ),
      ),
    );
  }

  void _onUndo(UndoLastAction event, Emitter<MeasurementState> emit) {
    if (state is! MeasurementInProgress) return;

    final currentState = state as MeasurementInProgress;
    if (currentState.undoStack.isEmpty) return;

    final previousMarkers = currentState.undoStack.last;
    final newUndoStack = currentState.undoStack.sublist(
      0,
      currentState.undoStack.length - 1,
    );

    final newRedoStack = [...currentState.redoStack, currentState.markers];

    emit(
      _calculateAndEmit(
        currentState.copyWith(
          markers: previousMarkers,
          undoStack: newUndoStack,
          redoStack: newRedoStack,
        ),
      ),
    );
  }

  void _onRedo(RedoLastEvent event, Emitter<MeasurementState> emit) {
    if (state is! MeasurementInProgress) return;
    final currentState = state as MeasurementInProgress;

    if (currentState.redoStack.isEmpty) return;
    final nextMarkers = currentState.redoStack.last;
    final newRedoStack = currentState.redoStack.sublist(
      0,
      currentState.redoStack.length - 1,
    );

    final newUndoStack = [...currentState.undoStack, currentState.markers];

    emit(
      _calculateAndEmit(
        currentState.copyWith(
          markers: nextMarkers,
          undoStack: newUndoStack,
          redoStack: newRedoStack,
        ),
      ),
    );
  }

  void _onChangeAreaUnit(
    ChangeAreaUnit event,
    Emitter<MeasurementState> emit,
  ) {
    if (state is! MeasurementInProgress) return;
    emit(
      (state as MeasurementInProgress).copyWith(
        areaUnit: event.unit,
      ),
    );
  }

  void _onChangeLengthUnit(
    ChangeLengthUnit event,
    Emitter<MeasurementState> emit,
  ) {
    if (state is! MeasurementInProgress) return;
    emit(
      (state as MeasurementInProgress).copyWith(
        lengthUnit: event.unit,
      ),
    );
  }

  void _onLocationUpdated(
    LocationUpdated event,
    Emitter<MeasurementState> emit,
  ) {
    if (state is! MeasurementInProgress) return;
    final currentState = state as MeasurementInProgress;
    if (currentState.isGpsTracking) {
      final newMarkers = [...currentState.markers, event.location];
      emit(
        _calculateAndEmit(
          currentState.copyWith(
            markers: newMarkers,
            currentLocation: event.location,
          ),
        ),
      );
    } else {
      emit(currentState.copyWith(currentLocation: event.location));
    }
  }

  Future<void> _onSavePlot(
    SavePlotEvent event,
    Emitter<MeasurementState> emit,
  ) async {
    if (state is! MeasurementInProgress) return;
    final currentState = state as MeasurementInProgress;

    if (currentState.markers.length < 3) {
      emit(MeasurementError('Need at least 3 points to save a plot'));
      emit(currentState);
      return;
    }

    emit(MeasurementLoading());

    final (failure, plot) = await _savePlotUseCase(
      SavePlotParams(
        name: event.name,
        coordinates: currentState.markers,
        areaInSquareMeters: currentState.areaInSqMeters ?? 0,
        perimeterInMeters: currentState.perimeterInMeters ?? 0,
        notes: event.notes,
      ),
    );

    if (failure != null) {
      emit(MeasurementError(failure.message));
      emit(currentState);
      return;
    }

    emit(MeasurementSaved(plot!));
  }

  MeasurementState _calculateAndEmit(MeasurementInProgress state) {
    if (state.markers.length < 2) {
      return state.copyWith(
        areaInSqMeters: null,
        perimeterInMeters: null,
        segmentLengths: [],
      );
    }

    final points = state.markers.map((c) => c.toLatLng()).toList();
    final perimeter = GeoCalculator.calculatePerimeter(points);
    final segments = GeoCalculator.getSegmentLengths(points);

    double? area;
    if (state.markers.length >= 3) {
      area = GeoCalculator.calculateArea(points);
    }

    return state.copyWith(
      areaInSqMeters: area,
      perimeterInMeters: perimeter,
      segmentLengths: segments,
    );
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    return super.close();
  }
}
