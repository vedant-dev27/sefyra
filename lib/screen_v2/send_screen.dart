import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sefyra/widgets/file_picker_widget.dart';
import 'package:sefyra/services/udp_catch.dart';
import 'package:sefyra/model/payload.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SendPage extends StatefulWidget {
  const SendPage({super.key});
  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  final udpcatch = UdpCatch();
  List<Payload> discoveredDevices = [];
  final Map<String, DateTime> _lastSeen = {};
  Timer? _cleanupTimer;

  void _initUdp() async {
    final prefs = await SharedPreferences.getInstance();
    await udpcatch.startUdp(
      ownId: prefs.getString("device_id") ?? "",
      onDeviceDiscovered: (Payload device) {
        if (!mounted) return;
        setState(() {
          _lastSeen[device.deviceId] = DateTime.now();
          final exists =
              discoveredDevices.any((d) => d.deviceId == device.deviceId);
          if (!exists) discoveredDevices.add(device);
        });
      },
    );

    _cleanupTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      final now = DateTime.now();
      setState(() {
        discoveredDevices.removeWhere((d) {
          final last = _lastSeen[d.deviceId];
          return last == null || now.difference(last).inSeconds > 10;
        });
      });
    });
  }

  IconData _iconForDeviceType(String type) {
    switch (type.toLowerCase()) {
      case 'tablet':
        return Icons.tablet_android_rounded;
      case 'laptop':
      case 'desktop':
        return Icons.laptop_rounded;
      case 'tv':
        return Icons.tv_rounded;
      default:
        return Icons.smartphone_rounded;
    }
  }

  @override
  void initState() {
    super.initState();
    _initUdp();
  }

  @override
  void dispose() {
    _cleanupTimer?.cancel();
    udpcatch.stopUdp();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Device list
            Expanded(
              child: discoveredDevices.isEmpty
                  ? Center(
                      child: Text("Scanning"),
                    )
                  : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      itemCount: discoveredDevices.length,
                      itemBuilder: (context, index) {
                        final device = discoveredDevices[index];
                        return _DeviceCard(
                          device: device,
                          icon: _iconForDeviceType(
                            device.deviceType,
                          ),
                        );
                      },
                    ),
            ),
            const FilePickerPanel(),
          ],
        ),
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final Payload device;
  final IconData icon;

  const _DeviceCard({required this.device, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Material(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(
          18,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(
            18,
          ),
          onTap: () {
            // TCP connect goes here
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 14,
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: colors.onPrimaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(
                  width: 14,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.deviceName,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        device.ipAddress,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurface.withValues(
                            alpha: 0.5,
                          ),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
