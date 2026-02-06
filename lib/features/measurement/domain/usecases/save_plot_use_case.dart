import 'package:equatable/equatable.dart';
import 'package:land_measure/core/error/failure.dart';
import 'package:land_measure/core/models/coordinate.dart';
import 'package:land_measure/core/models/land_plot.dart';
import 'package:land_measure/features/measurement/domain/repositories/plot_repository.dart';

class SavePlotUseCase {
  final PlotRepository _repository;

  SavePlotUseCase(this._repository);

  Future<(Failure?, LandPlot?)> call(SavePlotParams params) async {
    if (params.coordinates.length < 3) {
      return (
        const ValidationFailure('At least 3 coordinates are required'),
        null
      );
    }

    if (params.name.trim().isEmpty) {
      return (const ValidationFailure('Plot name cannot be empty'), null);
    }

    final plot = LandPlot(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: params.name.trim(),
      coordinates: params.coordinates,
      areaInSquareMeters: params.areaInSquareMeters,
      perimeterInMeters: params.perimeterInMeters,
      createdAt: DateTime.now(),
      notes: params.notes,
    );

    return _repository.savePlot(plot);
  }
}

class SavePlotParams extends Equatable {
  final String name;
  final List<Coordinate> coordinates;
  final double areaInSquareMeters;
  final double perimeterInMeters;
  final String? notes;

  const SavePlotParams({
    required this.name,
    required this.coordinates,
    required this.areaInSquareMeters,
    required this.perimeterInMeters,
    this.notes,
  });

  @override
  List<Object?> get props => [
        name,
        coordinates,
        areaInSquareMeters,
        perimeterInMeters,
        notes,
      ];
}
