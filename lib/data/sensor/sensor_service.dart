import 'mock_sensor_data_source.dart';

class SensorService {
  SensorService._internal();
  static final SensorService instance = SensorService._internal();

  final MockSensorDataSource dataSource = MockSensorDataSource();
}