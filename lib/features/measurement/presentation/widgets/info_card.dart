import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:land_measure/core/theme/app_theme.dart';
import 'package:land_measure/features/measurement/presentation/bloc/measurement_bloc.dart';
import 'package:land_measure/features/measurement/presentation/bloc/measurement_state.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MeasurementBloc, MeasurementState>(
      builder: (context, state) {
        if (state is! MeasurementInProgress) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: const BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              IntrinsicHeight(
                child: Row(
                  children: [
                    _MetricItem(label: 'AREA', value: state.formattedArea),
                    Divider(
                      color: AppColors.backgroundElevated,
                    ),
                    _MetricItem(
                      label: 'PERIMETER',
                      value: state.formattedPerimeter,
                    ),
                    Divider(
                      color: AppColors.backgroundElevated,
                    ),
                    _MetricItem(
                      label: 'POINTS',
                      value: '${state.markerCount}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;

  const _MetricItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppStyles.metricValue.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppStyles.metricLabel),
        ],
      ),
    );
  }
}
