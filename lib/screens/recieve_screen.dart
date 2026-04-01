import 'dart:io';
import 'package:flutter/material.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:sefyra/services/udp_send.dart';
import 'package:sefyra/model/broadcast_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sefyra/services/tcp_reciever.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  final SendBroadcast _sender = SendBroadcast();
  final TcpReceiver _tcpReceiver = TcpReceiver();

  String _status = "Waiting for files...";
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _initMediaStore();
    _startBroadcasting();
  }

  Future<void> _initMediaStore() async {
    // Required for Android 10+
    await MediaStore.ensureInitialized();
    MediaStore.appFolder = "Sefyra";
  }

  Future<String> _getLocalIp() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );

    for (final interface in interfaces) {
      for (final addr in interface.addresses) {
        final ip = addr.address;

        if (ip.startsWith('192.168.') ||
            ip.startsWith('10.') ||
            ip.startsWith('172.')) {
          return ip;
        }
      }
    }

    return '0.0.0.0';
  }

  /// Saves temp file into Android Downloads using MediaStore
  Future<String> _saveToDownloads(String tempPath, String fileName) async {
    final mediaStore = MediaStore();

    final saveInfo = await mediaStore.saveFile(
      tempFilePath: tempPath,
      dirType: DirType.download,
      dirName: DirName.download,
    );

    if (saveInfo == null) {
      throw Exception("MediaStore save failed");
    }

    // DO NOT delete temp file manually — plugin already handled it
    return saveInfo.uri.toString();
  }

  Future<void> _startBroadcasting() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    final deviceId = prefs.getString('device_id') ?? 'unknown';
    final deviceName = androidInfo.model;
    final ipAddress = await _getLocalIp();

    await _sender.start(
      BroadcastModel(
        deviceId: deviceId,
        deviceName: deviceName,
        ipAddress: ipAddress,
      ),
    );

    final tempDir = await getTemporaryDirectory();

    await _tcpReceiver.start(
      tempDirectory: tempDir.path,
      saveToDownloads: _saveToDownloads,
      onReceiveStart: (name) {
        setState(() {
          _status = "Receiving $name";
          _progress = 0;
        });
      },
      onProgress: (p) {
        setState(() => _progress = p);
      },
      onReceiveComplete: (path) {
        setState(() {
          _status = "Saved to Downloads";
          _progress = 1;
        });
      },
      onError: (e) {
        setState(() {
          _status = "Error: $e";
          _progress = 0;
        });
      },
    );
  }

  @override
  void dispose() {
    _sender.stop();
    _tcpReceiver.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Receive Files")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            SizedBox(
              width: 220,
              child: LinearProgressIndicator(value: _progress),
            ),
          ],
        ),
      ),
    );
  }
}
