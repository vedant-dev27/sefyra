import socket
import json
import threading
import time

UDP_PORT = 28167
TCP_PORT = 28170

def get_local_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(("8.8.8.8", 80))
    ip = s.getsockname()[0]
    s.close()
    return ip

def udp_broadcast():
    ip = get_local_ip()
    payload = {
        "deviceId": "python-001",
        "deviceName": "Python PC",
        "deviceType": "desktop",
        "ipAddress": ip
    }
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
    message = json.dumps(payload).encode()
    print(f"Broadcasting as 'Python PC' from {ip}")
    while True:
        sock.sendto(message, ("<broadcast>", UDP_PORT))
        time.sleep(2)
def tcp_server():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.bind(("0.0.0.0", TCP_PORT))
    server.listen(1)
    print(f"TCP server listening on port {TCP_PORT}")
    while True:
        conn, addr = server.accept()
        print(f"✅ Connected from {addr}")
        conn.makefile().read()  # wait until client closes
        print(f"❌ Disconnected from {addr}")
        conn.close()
        
threading.Thread(target=udp_broadcast, daemon=True).start()
tcp_server()