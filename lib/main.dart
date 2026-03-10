import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:land_measure/app.dart';
import 'package:land_measure/features/measurement/data/repositories/local_plot_repository.dart';
import 'package:land_measure/features/measurement/domain/usecases/save_plot_use_case.dart';
import 'package:land_measure/features/measurement/presentation/bloc/measurement_bloc.dart';
import 'package:land_measure/shared/services/location_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final locationService = LocationService();
  final plotRepository = LocalPlotRepository();
  final savePlotUseCase = SavePlotUseCase(plotRepository);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MeasurementBloc(
            locationService: locationService,
            savePlotUseCase: savePlotUseCase,
          ),
        ),
      ],
      child: const LandMeasureApp(),
    ),
  );
}
