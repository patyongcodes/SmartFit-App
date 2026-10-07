import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/app_drawer.dart';
import '../../data/sensor/sensor_service.dart';

class DevicePairingScreen extends StatefulWidget {
  const DevicePairingScreen({super.key});

  @override
  State<DevicePairingScreen> createState() => _DevicePairingScreenState();
}

class _DevicePairingScreenState extends State<DevicePairingScreen> {
  bool _isConnecting = true;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    await SensorService.instance.dataSource.connect();
    if (!mounted) return;
    setState(() => _isConnecting = false);
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = !_isConnecting;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Device Pairing'),
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Icon(Icons.bluetooth_searching, size: 56, color: colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                isConnected ? 'Devices Connected' : 'Searching for Devices...',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isConnected
                    ? 'Both sensor nodes are ready.'
                    : 'Make sure both wearable nodes are powered on.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 32),
              _buildNodeCard(context, 'Wrist Node', isConnected),
              const SizedBox(height: 12),
              _buildNodeCard(context, 'Chest Node', isConnected),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isConnected ? () => context.go('/calibration') : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    isConnected ? 'Continue to Calibration' : 'Connecting...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isConnected ? colorScheme.onPrimary : colorScheme.onSurface.withValues(alpha: 0.38),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNodeCard(BuildContext context, String label, bool isConnected) {
    final colorScheme = Theme.of(context).colorScheme;
    final successColor = colorScheme.tertiary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.bluetooth,
            color: isConnected ? successColor : colorScheme.onSurface.withValues(alpha: 0.6),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          if (isConnected)
            Row(
              children: [
                Icon(Icons.check_circle, color: successColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Connected',
                  style: TextStyle(
                    fontSize: 12,
                    color: successColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}