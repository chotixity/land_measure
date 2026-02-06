import 'package:land_measure/core/error/failure.dart';
import 'package:land_measure/core/models/land_plot.dart';
import 'package:land_measure/features/measurement/domain/repositories/plot_repository.dart';

/// In-memory implementation of PlotRepository.
/// Replace with Drift database implementation for persistence.
class LocalPlotRepository implements PlotRepository {
  final Map<String, LandPlot> _plots = {};

  @override
  Future<(Failure?, LandPlot?)> savePlot(LandPlot plot) async {
    try {
      _plots[plot.id] = plot;
      return (null, plot);
    } catch (e) {
      return (StorageFailure('Failed to save plot: $e'), null);
    }
  }

  @override
  Future<(Failure?, List<LandPlot>?)> getAllPlots() async {
    try {
      return (null, _plots.values.toList());
    } catch (e) {
      return (StorageFailure('Failed to fetch plots: $e'), null);
    }
  }

  @override
  Future<(Failure?, LandPlot?)> getPlotById(String id) async {
    try {
      final plot = _plots[id];
      if (plot == null) {
        return (const StorageFailure('Plot not found'), null);
      }
      return (null, plot);
    } catch (e) {
      return (StorageFailure('Failed to fetch plot: $e'), null);
    }
  }

  @override
  Future<(Failure?, void)> deletePlot(String id) async {
    try {
      _plots.remove(id);
      return (null, null);
    } catch (e) {
      return (StorageFailure('Failed to delete plot: $e'), null);
    }
  }
}
