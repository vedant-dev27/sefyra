import socket
import json

PORT = 41234 # use the same port as your Flutter UDP broadcast

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# allow reuse
sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

sock.bind(("", PORT))

print(f"Listening for UDP broadcasts on port {PORT}...\n")

while True:
    data, addr = sock.recvfrom(4096)

    try:
        message = data.decode("utf-8")
        parsed = json.loads(message)

        print("=== Packet Received ===")
        print(f"From: {addr}")
        print("Raw:", message)
        print("JSON:", parsed)
        print()

    except Exception as e:
        print("Invalid packet from", addr)
        print("Raw bytes:", data)
        print("Error:", e)
        print()