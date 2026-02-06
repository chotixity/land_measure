enum AreaUnit {
  squareMeters('sq m', 'Square Meters'),
  squareFeet('sq ft', 'Square Feet'),
  squareYards('sq yd', 'Square Yards'),
  acres('acres', 'Acres'),
  hectares('ha', 'Hectares'),
  squareKilometers('sq km', 'Square Kilometers')
  ;

  final String symbol;
  final String displayName;

  const AreaUnit(this.symbol, this.displayName);
}

enum LengthUnit {
  meters('m', 'Meters'),
  feet('ft', 'Feet'),
  yards('yd', 'Yards'),
  kilometers('km', 'Kilometers'),
  miles('mi', 'Miles')
  ;

  final String symbol;
  final String displayName;
  const LengthUnit(this.symbol, this.displayName);
}

class UnitConverter {
  /// Convert square meters to target unit
  static double convertArea(double squareMeters, AreaUnit unit) {
    return switch (unit) {
      AreaUnit.squareMeters => squareMeters,
      AreaUnit.squareFeet => squareMeters * 10.7639,
      AreaUnit.squareYards => squareMeters * 1.19599,
      AreaUnit.acres => squareMeters * 0.000247105,
      AreaUnit.hectares => squareMeters * 0.0001,
      AreaUnit.squareKilometers => squareMeters * 0.000001,
    };
  }

  /// Convert meters to target unit
  static double convertLength(double meters, LengthUnit unit) {
    return switch (unit) {
      LengthUnit.meters => meters,
      LengthUnit.feet => meters * 3.28084,
      LengthUnit.yards => meters * 1.09361,
      LengthUnit.kilometers => meters * 0.001,
      LengthUnit.miles => meters * 0.000621371,
    };
  }

  /// Format area with appropriate precision
  static String formatArea(double value, AreaUnit unit) {
    final converted = convertArea(value, unit);
    if (converted >= 1000) {
      return '${converted.toStringAsFixed(1)} ${unit.symbol}';
    } else if (converted >= 1) {
      return '${converted.toStringAsFixed(2)} ${unit.symbol}';
    } else {
      return '${converted.toStringAsFixed(4)} ${unit.symbol}';
    }
  }

  /// Format length with appropriate precision
  static String formatLength(double value, LengthUnit unit) {
    final converted = convertLength(value, unit);
    if (converted >= 1000) {
      return '${converted.toStringAsFixed(1)} ${unit.symbol}';
    } else if (converted >= 1) {
      return '${converted.toStringAsFixed(2)} ${unit.symbol}';
    } else {
      return '${converted.toStringAsFixed(3)} ${unit.symbol}';
    }
  }
}
