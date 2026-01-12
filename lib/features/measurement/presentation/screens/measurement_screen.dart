import 'package:flutter/material.dart';

class MeasurementScreen extends StatelessWidget {
  const MeasurementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(centerTitle: true,title: Text('Land Measure', style: Theme.of(context).textTheme.titleMedium,),),);
  }
}