import socket, json, time

payload = json.dumps({
    "deviceId": "pc-test-001",
    "deviceName": "Solstice",
    "ipAddress": "192.168.1.29"  
}).encode()

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)

while True:
    sock.sendto(payload, ('255.255.255.255', 41234))
    print("sent")
    time.sleep(2)

