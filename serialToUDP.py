#!/usr/bin/python

import sys, getopt, socket, serial, re, time
from OSC import OSCClient, OSCMessage

def parse(argv):
  UDP_IP = 'localhost'
  UDP_PORT = 7565

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
      UDP_PORT = int(arg)
    elif opt in ('-s', '--serial'):
      SERIAL_PORT = arg
    elif opt in ('-b', '--baud'):
      SERIAL_BAUD_RATE = int(arg)

  return dict(udp = (UDP_IP, UDP_PORT), serial = (SERIAL_PORT, SERIAL_BAUD_RATE))

if __name__ == '__main__':
  connection = parse(sys.argv[1:])

  print('Listening to serial port {0} @ {1}'.format(connection['serial'][0], connection['serial'][1]))
  print('Broadcasting to http://{0}:{1}'.format(connection['udp'][0], connection['udp'][1]))

  sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
  client = OSCClient()
  client.connect(connection['udp'])
  ser = serial.Serial(connection['serial'][0], connection['serial'][1])

  start = time.time()
  averages = [ 0, 0, 0, 0 ]
  count = 0
  findAverage = True
  while True:
    #buf = ser.readline()
    captures = map(int, re.findall(r'\d+', ser.readline()))

    if time.time() - start < 5.0:
      count += 1

      averages[0] += captures[0]
      averages[1] += captures[1]
      averages[2] += captures[2]
      averages[3] += captures[3]

    else:
      if findAverage:
        findAverage = False

        averages[0] /= count
        averages[1] /= count
        averages[2] /= count
        averages[3] /= count

        print('Average:', averages)

      data = []
      for i in range(4):
        if captures[i] - averages[i] > 0:
          data[i] = captures[i] - averages[i]
        else:
          data[i] = 0

      print('Captures:', captures, 'Converted:', data)

      #sock.sendto(buf, connection['udp'])
      client.send(OSCMessage('/1/fader1', data[0])) # Flex sensor
      client.send(OSCMessage('/1/fader2', data[1])) # Flex sensor
      client.send(OSCMessage('/1/fader3', data[2])) # Accelerometer
      client.send(OSCMessage('/1/fader5', data[3])) # Pressure