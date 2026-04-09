import 'package:flutter/material.dart';
import 'package:sefyra/services/device_config.dart';
import 'package:sefyra/services/tcp_server.dart';
import 'package:sefyra/services/udp_fire.dart';
import 'package:sefyra/model/payload.dart';
import 'package:sefyra/services/ip_config.dart';
import 'package:sefyra/widgets/loading_widget.dart';
import 'package:sefyra/widgets/ripple_widget.dart';

class RecievePage extends StatefulWidget {
  final TcpServer tcpServer;

  const RecievePage({
    super.key,
    required this.tcpServer,
  });

  @override
  State<RecievePage> createState() => _RecievePageState();
}

class _RecievePageState extends State<RecievePage> {
  final UdpFire udpFire = UdpFire();

  late final TcpServer tcpServer;

  String named = "";
  String devid = "";
  bool showCompleted = false;

  late final VoidCallback _progressListener;

  @override
  void initState() {
    super.initState();

    tcpServer = widget.tcpServer;

    _initUdp();

    _progressListener = () {
      if (tcpServer.progress.value >= 0.999) {
        if (!showCompleted && mounted) {
          setState(() => showCompleted = true);

          Future.delayed(const Duration(milliseconds: 1200), () {
            if (!mounted) return;
            setState(() => showCompleted = false);
          });
        }
      }
    };

    tcpServer.progress.addListener(_progressListener);
  }

  void _initUdp() async {
    final name = await getDeviceName();
    final id = await getStoreID();
    final ip = await getLocalIp();
    if (!mounted) return;

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
  void dispose() {
    tcpServer.progress.removeListener(_progressListener);
    udpFire.stopUdp();
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
                    SizedBox(
                      height: 330,
                      width: 330,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: showCompleted
                            ? const _CompletedView(key: ValueKey('done'))
                            : ValueListenableBuilder<bool>(
                                key: const ValueKey('main'),
                                valueListenable: tcpServer.isTransferring,
                                builder: (context, isTransferring, _) {
                                  if (!isTransferring) {
                                    return const RippleWidget(
                                        key: ValueKey('ripple'));
                                  }

                                  return ValueListenableBuilder<double>(
                                    valueListenable: tcpServer.progress,
                                    builder: (context, progress, _) {
                                      return Stack(
                                        key: const ValueKey('progress'),
                                        alignment: Alignment.center,
                                        children: [
                                          WavyProgressIndicator(
                                              progress: progress),
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
                                  );
                                },
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ValueListenableBuilder<bool>(
                      valueListenable: tcpServer.isTransferring,
                      builder: (context, isTransferring, _) {
                        if (!isTransferring) {
                          return Column(
                            children: [
                              Text(
                                named,
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w600,
                                  color: colors.primary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Ready to receive",
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          );
                        }

                        return ValueListenableBuilder<String?>(
                          valueListenable: tcpServer.currentFileName,
                          builder: (context, fileName, _) {
                            return ValueListenableBuilder<String?>(
                              valueListenable: tcpServer.senderName,
                              builder: (context, sender, _) {
                                return Column(
                                  children: [
                                    Text(
                                      fileName ?? "...",
                                      style: TextStyle(
                                        fontSize: 42,
                                        fontWeight: FontWeight.w600,
                                        color: colors.primary,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Receiving from ${sender ?? "Unknown device"}',
                                      style: TextStyle(
                                        fontSize: 22,
                                        color: sender != null
                                            ? colors.onSurface.withAlpha(180)
                                            : colors.error,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                    )
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

class _CompletedView extends StatelessWidget {
  const _CompletedView({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: 300,
      height: 300,
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
            "File received",
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
