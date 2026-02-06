import 'package:land_measure/core/error/failure.dart';
import 'package:land_measure/core/models/land_plot.dart';

abstract class PlotRepository {
  Future<(Failure?, LandPlot?)> savePlot(LandPlot plot);
  Future<(Failure?, List<LandPlot>?)> getAllPlots();
  Future<(Failure?, LandPlot?)> getPlotById(String id);
  Future<(Failure?, void)> deletePlot(String id);
}
