import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sefyra/services/tcp_client.dart';
import 'package:sefyra/services/udp_catch.dart';
import 'package:sefyra/model/payload.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sefyra/widgets/file_picker_widget.dart';

class SendPage extends StatefulWidget {
  const SendPage({super.key});

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  final UdpCatch _udp = UdpCatch();

  final List<Payload> _devices = [];
  final Map<String, DateTime> _lastSeen = {};
  Timer? _cleanupTimer;

  String? _selectedFile; // 🔥 single source of truth

  @override
  void initState() {
    super.initState();
    _startDiscovery();
  }

  @override
  void dispose() {
    _cleanupTimer?.cancel();
    _udp.stopUdp();
    super.dispose();
  }

  Future<void> _startDiscovery() async {
    final prefs = await SharedPreferences.getInstance();

    await _udp.startUdp(
      ownId: prefs.getString("device_id") ?? "",
      onDeviceDiscovered: _handleDevice,
    );

    _cleanupTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _cleanupDevices(),
    );
  }

  void _handleDevice(Payload device) {
    if (!mounted) return;

    setState(() {
      _lastSeen[device.deviceId] = DateTime.now();

      final exists = _devices.any((d) => d.deviceId == device.deviceId);
      if (!exists) _devices.add(device);
    });
  }

  void _cleanupDevices() {
    if (!mounted) return;

    final now = DateTime.now();

    setState(() {
      _devices.removeWhere((d) {
        final last = _lastSeen[d.deviceId];
        return last == null || now.difference(last).inSeconds > 2;
      });
    });
  }

  void _onFilePicked(String? filePath) {
    if (filePath == null) return;

    setState(() {
      _selectedFile = filePath;
    });

    print("Selected file: $_selectedFile");
  }

  Future<void> _sendFile(String ip) async {
    if (_selectedFile == null) {
      print("No file selected");
      return;
    }

    await TcpClient.tcpConnect(ip, _selectedFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _devices.isEmpty
                  ? const Center(child: Text("Scanning..."))
                  : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _devices.length,
                      itemBuilder: (context, index) {
                        final device = _devices[index];

                        return DeviceCard(
                          device: device,
                          onTap: () => _sendFile(device.ipAddress),
                        );
                      },
                    ),
            ),
            FilePickerPanel(
              onFilePicked: _onFilePicked,
            ),
          ],
        ),
      ),
    );
  }
}

class DeviceCard extends StatelessWidget {
  final Payload device;
  final VoidCallback onTap;

  const DeviceCard({
    super.key,
    required this.device,
    required this.onTap,
  });

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'tablet':
        return Icons.tablet;
      case 'laptop':
      case 'desktop':
        return Icons.laptop;
      case 'tv':
        return Icons.tv;
      default:
        return Icons.smartphone;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
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
                    _iconForType(device.deviceType),
                    color: colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.deviceName,
                        style: text.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        device.ipAddress,
                        style: text.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: colors.onSurface.withValues(alpha: 0.5),
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
