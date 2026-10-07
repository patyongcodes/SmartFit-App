import 'sensor_reading.dart';

abstract class SensorDataSource {
  Stream<SensorReading> get readings;
  bool get isConnected;

  Future<void> connect();
  Future<void> disconnect();
  Future<void> calibrate();
  Future<void> startStreaming();
}