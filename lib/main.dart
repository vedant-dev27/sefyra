import 'package:flutter/material.dart';
import 'package:sefyra/screen_v2/recieve_screen.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:sefyra/screen_v2/send_screen.dart';
import 'package:sefyra/services/tcp_server.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'dart:async';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await MediaStore.ensureInitialized();
  MediaStore.appFolder = "Sefyra";
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightScheme, darkScheme) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.system,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightScheme ??
                ColorScheme.fromSeed(
                  seedColor: const Color(0xFF0063D4),
                ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkScheme ??
                ColorScheme.fromSeed(
                  seedColor: const Color(0xFF0063D4),
                  brightness: Brightness.dark,
                ),
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TcpServer tcpServer = TcpServer();

  @override
  void initState() {
    super.initState();
    tcpServer.startTCP();
  }

  @override
  void dispose() {
    tcpServer.stopTCP();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<bool>(
        valueListenable: tcpServer.isTransferring,
        builder: (context, isTransferring, _) {
          return PageView(
            physics: isTransferring
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            children: [
              RecievePage(tcpServer: tcpServer),
              SendPage(tcpServer: tcpServer),
            ],
          );
        },
      ),
    );
  }
}
