enum OptimizeValue {
  low(1.5, 95),
  moderate(1.25, 90),
  high(1, 85),
  aggressive(0.75, 70),
  ;

  const OptimizeValue(this.scaleValue, this.quality);

  final double scaleValue;

  final int quality;
}
