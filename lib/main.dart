import 'package:sefyra/screens/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:sefyra/services/uid_gen_store.dart';

void main() async {
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
