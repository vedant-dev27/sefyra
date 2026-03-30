//Generates and store deviceid

import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> getStoreID() async {
  final pref = await SharedPreferences.getInstance();

  String? id = pref.getString("device_id");

  if (id == null) {
    id = Uuid().v4();
    await pref.setString("device_id", id);
  }
  return id;
}
