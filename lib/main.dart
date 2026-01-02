import 'package:flutter/material.dart';

void main() {
  runApp(const LandMeasure());
}

class LandMeasure extends StatelessWidget {
  const LandMeasure({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Center(child: Text("This is  a land Measure App"),)
    );
  }
}

