import 'package:flutter/material.dart';
import 'package:sefyra/screen_v2/recieve.dart';
import 'package:sefyra/screen_v2/send.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color vibrantBlue = Color(0xFF0063D4);

  static final ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: vibrantBlue,
    onPrimary: Colors.white,
    secondary: vibrantBlue,
    onSecondary: Colors.white,
    tertiary: Colors.purpleAccent,
    onTertiary: Colors.white,
    surface: Colors.white,
    onSurface: Colors.black,
    error: Colors.red,
    onError: Colors.white,
  );

  static final ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: vibrantBlue,
    onPrimary: Colors.white,
    secondary: vibrantBlue,
    onSecondary: Colors.white,
    tertiary: Colors.purpleAccent,
    onTertiary: Colors.white,
    surface: const Color(0xFF121212),
    onSurface: Colors.white,
    error: Colors.red,
    onError: Colors.black,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightScheme,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkScheme,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController controller;

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: 1000);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: controller,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return index % 2 == 0 ? RecievePage() : SendPage();
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.history,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(
                    Icons.settings,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
