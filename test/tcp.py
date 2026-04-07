import socket

HOST = '172.16.176.43'  # replace with receiver's IP
PORT = 28167
FILE = 'test.txt'     # replace with your file path

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.connect((HOST, PORT))
    print(f'Connected to {HOST}:{PORT}')

    with open(FILE, 'rb') as f:
        while chunk := f.read(65536):
            s.sendall(chunk)

    print('Done')