import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<String> _adj = [];
List<String> _nouns = [];
final _random = Random();

Future<void> loadTxt() async {
  final nounString = await rootBundle.loadString('assets/name/b.txt');
  final adjString = await rootBundle.loadString('assets/name/a.txt');

  _nouns = nounString
      .split('\n')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  _adj = adjString
      .split('\n')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}

String _generateName() {
  final adj = _adj[_random.nextInt(_adj.length)];
  final noun = _nouns[_random.nextInt(_nouns.length)];
  return "$adj $noun";
}

Future<String> getDeviceName() async {
  final pref = await SharedPreferences.getInstance();
  String? deviceName = pref.getString("deviceName");

  if (deviceName == null) {
    if (_adj.isEmpty || _nouns.isEmpty) {
      await loadTxt();
    }
    deviceName = _generateName();
    await pref.setString("deviceName", deviceName);
  }
  return deviceName;
}

//Generates and store deviceid
Future<String> getStoreID() async {
  final pref = await SharedPreferences.getInstance();

  String? id = pref.getString("device_id");

  if (id == null) {
    id = Uuid().v4();
    await pref.setString("device_id", id);
  }
  return id;
}
