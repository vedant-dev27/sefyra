import 'package:sefyra/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:sefyra/services/uid_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await getStoreID();
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Homescreen(),
    );
  }
}
