#!/usr/bin/python

import sys, getopt, socket, serial


def main(argv):
  UDP_IP = 'localhost'
  UDP_PORT = 9000

  SERIAL_PORT = '/dev/ttyACM0'
  SERIAL_BAUD_RATE = 9600

  try:
    opts, args = getopt.getopt(argv, "hi:p:s:b:", ['ip=', 'port=', 'serial=', 'baud='])
  except getopt.GetoptError:
    print('Usage: ./serialToUDP.py -i <IP address> -p <IP port> -s <Serial port> -b <Baud rate>')
    sys.exit(2)

  for opt, arg in opts:
    if opt == '-h':
      print('Usage: ./serialToUDP.py -i <IP address> -p <IP port> -s <Serial port> -b <Baud rate>')
      return
    elif opt in ('-i', '--ip'):
      UDP_IP = arg
    elif opt in ('-p', '--port'):
      UDP_PORT = arg
    elif opt in ('-s', '--serial'):
      SERIAL_PORT = arg
    elif opt in ('-b', '--baud'):
      SERIAL_BAUD_RATE = arg

  print('Listening to serial {0} @ baud rate {1}'.format(SERIAL_PORT, SERIAL_BAUD_RATE))
  print('Broadcasting to {0}:{1}'.format(UDP_IP, UDP_PORT))

  sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
  ser = serial.Serial(SERIAL_PORT, SERIAL_BAUD_RATE)

  while True:
    buf = ser.readline()
    sock.sendto(buf, (UDP_IP, UDP_PORT))

if __name__ == '__main__':
  main(sys.argv[1:])
