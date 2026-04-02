class Payload {
  final String deviceId;
  final String deviceName;
  final String deviceType;
  final String ipAddress;

  Payload({
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    required this.ipAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      "deviceId": deviceId,
      "deviceName": deviceName,
      "deviceType": deviceType,
      "ipAddress": ipAddress,
    };
  }

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      deviceId: json['deviceId'],
      deviceName: json['deviceName'],
      deviceType: json['deviceType'],
      ipAddress: json['ipAddress'],
    );
  }
}
