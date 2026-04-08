import 'package:flutter/material.dart';
import 'package:sefyra/services/device_config.dart';
import 'package:sefyra/services/tcp_server.dart';
import 'package:sefyra/services/udp_fire.dart';
import 'package:sefyra/model/payload.dart';
import 'package:sefyra/services/ip_config.dart';
import 'package:sefyra/widgets/ripple_widget.dart';

class RecievePage extends StatefulWidget {
  const RecievePage({super.key});

  @override
  State<RecievePage> createState() => _RecievePageState();
}

class _RecievePageState extends State<RecievePage> {
  final UdpFire udpFire = UdpFire();
  String named = "";
  String devid = "";

  void _initUdp() async {
    final name = await getDeviceName();
    final id = await getStoreID();
    final ip = await getLocalIp();

    setState(() {
      named = name;
      devid = id;
    });

    final payload = Payload(
      deviceId: id,
      deviceName: name,
      deviceType: "phone",
      ipAddress: ip ?? "0.0.0.0",
    );

    udpFire.startUdp(payload);
  }

  @override
  void initState() {
    super.initState();
    _initUdp();
    TcpServer.startTCP();
  }

  @override
  void dispose() {
    udpFire.stopUdp();
    TcpServer.stopTCP();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 250,
                      width: 250,
                      child: RippleWidget(),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      named,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Ready to receive",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: colors.onSurface.withValues(alpha: 0.6),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
