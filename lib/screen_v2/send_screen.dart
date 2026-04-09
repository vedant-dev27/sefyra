import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sefyra/services/tcp_client.dart';
import 'package:sefyra/services/tcp_server.dart';
import 'package:sefyra/services/udp_catch.dart';
import 'package:sefyra/model/payload.dart';
import 'package:sefyra/widgets/device_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sefyra/widgets/file_picker_widget.dart';
import 'package:sefyra/widgets/loading_widget.dart';

class SendPage extends StatefulWidget {
  final TcpServer tcpServer;

  const SendPage({
    super.key,
    required this.tcpServer,
  });

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  late final TcpServer tcpServer;

  final UdpCatch _udp = UdpCatch();

  final List<Payload> _devices = [];
  final Map<String, DateTime> _lastSeen = {};
  Timer? _cleanupTimer;

  String? _selectedFile;
  String? _fileToSend;
  String? _receiverName;
  bool _isSending = false;
  bool _showCompleted = false;
  final ValueNotifier<double> _sendProgress = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    tcpServer = widget.tcpServer;
    _startDiscovery();
  }

  @override
  void dispose() {
    _sendProgress.dispose();
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
    setState(() => _selectedFile = filePath);
  }

  Future<void> _sendFile(String ip, String deviceName) async {
    if (_selectedFile == null || _isSending) return;

    final captured = _selectedFile!;

    setState(() {
      _isSending = true;
      _receiverName = deviceName;
      _fileToSend = captured;
    });
    _sendProgress.value = 0.0;

    await TcpClient.tcpConnect(
      ip,
      captured,
      onProgress: (sent, total) {
        _sendProgress.value = sent / total;
      },
    );

    if (!mounted) return;

    _sendProgress.value = 0.0;
    setState(() {
      _isSending = false;
      _showCompleted = true;
      _selectedFile = null;
      _fileToSend = null;
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _showCompleted = false;
        _receiverName = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _showCompleted
              ? const _CompletedView(key: ValueKey('done'))
              : _isSending
                  ? Center(
                      key: const ValueKey('sending'),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ValueListenableBuilder<double>(
                            valueListenable: _sendProgress,
                            builder: (context, progress, _) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  WavyProgressIndicator(progress: progress),
                                  Text(
                                    "${(progress * 100).toStringAsFixed(0)}%",
                                    style: TextStyle(
                                      fontSize: 42,
                                      fontWeight: FontWeight.w600,
                                      color: colors.primary,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _fileToSend?.split('/').last ?? '',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w600,
                              color: colors.primary,
                              letterSpacing: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Sending to ${_receiverName ?? '...'}",
                            style: TextStyle(
                              fontSize: 20,
                              color: colors.onSurface.withAlpha(180),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    )
                  : Column(
                      key: const ValueKey('idle'),
                      children: [
                        Expanded(
                          child: _devices.isEmpty
                              ? const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.radar,
                                        size: 64,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        "Looking for devices",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  reverse: true,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  itemCount: _devices.length,
                                  itemBuilder: (context, index) {
                                    final device = _devices[index];
                                    return DeviceCard(
                                      device: device,
                                      onTap: () => _sendFile(
                                          device.ipAddress, device.deviceName),
                                    );
                                  },
                                ),
                        ),
                        FilePickerPanel(
                          selectedFile: _selectedFile,
                          onFilePicked: _onFilePicked,
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}

class _CompletedView extends StatelessWidget {
  const _CompletedView({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: Icon(
              Icons.check_circle_rounded,
              size: 120,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "File sent",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
