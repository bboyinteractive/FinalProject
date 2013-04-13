import socket
import serial

UDP_IP = 'localhost'
UDP_PORT = 9000

SERIAL_PORT = '/dev/ttyACM0'
SERIAL_BAUD_RATE = 19200
SERIAL_TIMEOUT = 0

if __name__ == '__main__':
  sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
  ser = serial.Serial(SERIAL_PORT, SERIAL_BAUD_RATE, SERIAL_TIMEOUT)

  while True:
    buf = ser.readline()
    sock.sendto(buf, (UDP_IP, UDP_PORT))
