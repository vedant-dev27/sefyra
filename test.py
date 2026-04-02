import socket
import json
import time
import uuid

payload = {
    "deviceId": str(uuid.uuid4()),
    "deviceName": "Test Laptop",
    "deviceType": "laptop",
    "ipAddress": "192.168.1.100"
}

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)

print(f"Broadcasting as: {payload['deviceName']} ({payload['deviceId']})")

while True:
    message = json.dumps(payload).encode('utf-8')
    sock.sendto(message, ('255.255.255.255', 28167))
    print("Broadcast sent")
    time.sleep(2)