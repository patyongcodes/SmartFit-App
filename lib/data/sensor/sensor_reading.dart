class SensorReading {
  final double wristAngularVelocity;
  final double torsoLeanAngle;
  final double jerk;
  final int heartRate;
  final DateTime timestamp;

  const SensorReading({
    required this.wristAngularVelocity,
    required this.torsoLeanAngle,
    required this.jerk,
    required this.heartRate,
    required this.timestamp,
  });
}