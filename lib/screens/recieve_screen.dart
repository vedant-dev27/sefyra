import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sefyra/services/udp_send.dart';
import 'package:sefyra/model/broadcast_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';

class RecieveScreen extends StatefulWidget {
  const RecieveScreen({super.key});

  @override
  State<RecieveScreen> createState() => _RecieveScreenState();
}

class _RecieveScreenState extends State<RecieveScreen> {
  final SendBroadcast _sender = SendBroadcast();

  @override
  void initState() {
    super.initState();
    _startBroadcasting();
  }

  Future<String> _getLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );

      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          final ip = addr.address;

          // Prefer private LAN IP ranges
          if (ip.startsWith('192.168.') ||
              ip.startsWith('10.') ||
              ip.startsWith('172.')) {
            return ip;
          }
        }
      }
    } catch (e) {
      debugPrint("Error getting IP: $e");
    }

    return '0.0.0.0';
  }

  Future<void> _startBroadcasting() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    final deviceId = prefs.getString('device_id') ?? '';
    final deviceName = androidInfo.model;
    final ipAddress = await _getLocalIp();

    await _sender.start(
      BroadcastModel(
        deviceId: deviceId,
        deviceName: deviceName,
        ipAddress: ipAddress,
      ),
    );
  }

  @override
  void dispose() {
    _sender.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Receiving..."),
      ),
    );
  }
}
