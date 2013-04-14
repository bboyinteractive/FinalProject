#!/usr/bin/python

import sys, getopt, socket, serial

def parse(argv):
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

  return dict(udp = (UDP_IP, UDP_PORT), serial = (SERIAL_PORT, SERIAL_BAUD_RATE))

if __name__ == '__main__':
  connection = parse(sys.argv[1:])

  print('Listening to serial port {0} @ {1}'.format(connection['serial'][0], connection['serial'][1]))
  print('Broadcasting to http://{0}:{1}'.format(connection['udp'][0], connection['udp'][1]))

  sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
  ser = serial.Serial(connection['serial'][0], connection['serial'][1])

  while True:
    sock.sendto(ser.readline(), connection['udp'])
