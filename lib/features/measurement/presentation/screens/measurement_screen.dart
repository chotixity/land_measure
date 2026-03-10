import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:land_measure/core/theme/app_theme.dart';
import 'package:land_measure/features/measurement/presentation/bloc/measurement_bloc.dart';
import 'package:land_measure/features/measurement/presentation/bloc/measurement_event.dart';
import 'package:land_measure/features/measurement/presentation/bloc/measurement_state.dart';
import 'package:land_measure/features/measurement/presentation/widgets/google_maps_view.dart';

class MeasurementScreen extends StatefulWidget {
  const MeasurementScreen({super.key});

  @override
  State<MeasurementScreen> createState() => _MeasurementScreenState();
}

class _MeasurementScreenState extends State<MeasurementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MeasurementBloc>().add(Initializemeasurement());
  }

  void _showSaveDialog() {
    final nameController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Save Plot'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Enter plot name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(80, 40),
            ),
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              context.read<MeasurementBloc>().add(SavePlotEvent(name));
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MeasurementBloc, MeasurementState>(
      listener: (context, state) {
        if (state is MeasurementSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Plot "${state.plot.name}" saved!')),
          );
          context.read<MeasurementBloc>().add(Initializemeasurement());
        } else if (state is MeasurementError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: CircleAvatar(
            backgroundColor: AppColors.backgroundDark,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          title: BlocBuilder<MeasurementBloc, MeasurementState>(
            builder: (context, state) {
              final isTracking =
                  state is MeasurementInProgress && state.isGpsTracking;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.backgroundDark,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    Icon(
                      Icons.satellite_alt,
                      size: 16,
                      color: isTracking
                          ? AppColors.neonGreen
                          : AppColors.textSecondary,
                    ),
                    Text(
                      isTracking ? 'GPS Active' : 'GPS Ready',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            CircleAvatar(
              backgroundColor: AppColors.backgroundDark,
              child: IconButton(
                icon: const Icon(Icons.settings, color: AppColors.textPrimary),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Stack(
          children: [
            const GoogleMapsView(),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BlocBuilder<MeasurementBloc, MeasurementState>(
                builder: (context, state) {
                  if (state is! MeasurementInProgress) {
                    return const SizedBox.shrink();
                  }
                  if (state.isGpsTracking) {
                    return _TrackingPanel(markerCount: state.markerCount);
                  }
                  if (state.markers.isNotEmpty) {
                    return _DonePanel(
                      state: state,
                      onSave: _showSaveDialog,
                    );
                  }
                  return const _IdlePanel();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Idle ─────────────────────────────────────────────────────────────────────

class _IdlePanel extends StatelessWidget {
  const _IdlePanel();

  @override
  Widget build(BuildContext context) {
    return _BottomCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 12,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.route, color: AppColors.neonGreen),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ready to Measure',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    'Walk the boundary of your land',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () =>
                context.read<MeasurementBloc>().add(StartGpsTracking()),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Measuring'),
          ),
        ],
      ),
    );
  }
}

// ─── Tracking ─────────────────────────────────────────────────────────────────

class _TrackingPanel extends StatelessWidget {
  final int markerCount;

  const _TrackingPanel({required this.markerCount});

  @override
  Widget build(BuildContext context) {
    final canFinish = markerCount >= 3;

    return _BottomCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const _PulseDot(),
              const SizedBox(width: 8),
              Text(
                'Recording...',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: AppColors.error),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.backgroundElevated,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$markerCount pts',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ),
          if (!canFinish) ...[
            const SizedBox(height: 8),
            Text(
              'Keep walking — need ${3 - markerCount} more GPS point${3 - markerCount == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    final bloc = context.read<MeasurementBloc>();
                    bloc.add(StopGpsTracking());
                    bloc.add(ClearAllMarkersEvent());
                  },
                  child: const Text('Cancel'),
                ),
              ),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: canFinish
                      ? () => context.read<MeasurementBloc>().add(
                          StopGpsTracking(),
                        )
                      : null,
                  icon: const Icon(Icons.check),
                  label: const Text('Done'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Done ─────────────────────────────────────────────────────────────────────

class _DonePanel extends StatelessWidget {
  final MeasurementInProgress state;
  final VoidCallback onSave;

  const _DonePanel({required this.state, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return _BottomCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                _Metric(label: 'AREA', value: state.formattedArea),
                const _VerticalDivider(),
                _Metric(label: 'PERIMETER', value: state.formattedPerimeter),
                const _VerticalDivider(),
                _Metric(label: 'POINTS', value: '${state.markerCount}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.read<MeasurementBloc>().add(
                    ClearAllMarkersEvent(),
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
              ),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: onSave,
                  icon: const Icon(Icons.save_alt),
                  label: const Text('Save Plot'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Shared primitives ────────────────────────────────────────────────────────

class _BottomCard extends StatelessWidget {
  final Widget child;

  const _BottomCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
          child,
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppStyles.metricValue.copyWith(fontSize: 20)),
          const SizedBox(height: 4),
          Text(label, style: AppStyles.metricLabel),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, color: AppColors.backgroundElevated);
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.error.withAlpha(
            (_controller.value * 155 + 100).toInt(),
          ),
        ),
      ),
    );
  }
}
