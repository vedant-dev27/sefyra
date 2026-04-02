import socket

PORT = 28167  # use SAME port as your Flutter app

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind(("", PORT))  # listen on all interfaces

print("Listening for UDP broadcasts...\n")

while True:
    data, addr = sock.recvfrom(1024)
    message = data.decode()

    print(f"Received from {addr}: {message}")