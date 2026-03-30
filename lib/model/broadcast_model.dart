// Data sent in UDP broadcast
class BroadcastModel {
  final String deviceName;
  final String ipAddress;
  final String deviceId;

  BroadcastModel({
    required this.deviceId,
    required this.deviceName,
    required this.ipAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      "deviceName": deviceName,
      "ipAddress": ipAddress,
      "deviceId": deviceId,
    };
  }
}
