import 'dart:async';
import 'dart:math';
import 'sensor_data_source.dart';
import 'sensor_reading.dart';

class MockSensorDataSource implements SensorDataSource {
  final _controller = StreamController<SensorReading>.broadcast();
  final _random = Random();
  Timer? _timer;
  bool _connected = false;
  int _tick = 0;

  @override
  Stream<SensorReading> get readings => _controller.stream;

  @override
  bool get isConnected => _connected;

  @override
  Future<void> connect() async {
    await Future.delayed(const Duration(seconds: 2));
    _connected = true;
  }

  @override
  Future<void> disconnect() async {
    _timer?.cancel();
    _connected = false;
  }

  @override
  Future<void> calibrate() async {
    await Future.delayed(const Duration(seconds: 3));
  }

  @override
  Future<void> startStreaming() async {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      _tick++;
      // Every 9th tick simulates a bad rep (spike in speed/lean/jerk) so
      // the Form Warning modal has something real to react to.
      final isSpike = _tick % 9 == 0;

      final angularVelocity = 90 + _random.nextDouble() * 20 - 10 + (isSpike ? 60 : 0);
      final leanAngle = 5 + _random.nextDouble() * 6 + (isSpike ? 14 : 0);
      final jerk = 4 + _random.nextDouble() * 4 + (isSpike ? 10 : 0);
      final heartRate = 110 + (_tick % 20) + _random.nextInt(6);

      _controller.add(SensorReading(
        wristAngularVelocity: angularVelocity,
        torsoLeanAngle: leanAngle,
        jerk: jerk,
        heartRate: heartRate,
        timestamp: DateTime.now(),
      ));
    });
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}