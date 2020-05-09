import paho.mqtt.client as mqttClient
import time
import serial
import sys
import crcmod.predefined

crc16 = crcmod.predefined.mkCrcFun('crc-16')

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("Connected to broker")
        global Connected
        Connected = True
    else:
        print("Connection failed")

Connected = False
port = 1883
broker_address= sys.argv[1]
COM = sys.argv[2]
room = sys.argv[3]

client = mqttClient.Client()
client.on_connect= on_connect
client.connect(broker_address, port=port)
client.loop_start()

ser = serial.Serial(COM)

def pub():
    rawdata = ser.readline()
    try:
        rawdata = rawdata.decode().strip()
    except:
        print("Failed to decode message")
        print(rawdata)
        return
    try:
        pyCRC = hex(crc16(rawdata[0:rawdata.rfind(',')].encode('utf-8')))
        data = rawdata.split(',')
        arduinoCRC = hex(int(data[-1]))
        if not pyCRC == arduinoCRC:
            raise Exception("Failed checksum check")
        data = list(map(float, data[0:4]))
        client.publish("hassio/"+room+"/temperature",data[0])
        client.publish("hassio/"+room+"/humidity",data[1])
        client.publish("hassio/"+room+"/light",data[2])
        client.publish("hassio/"+room+"/pressure",data[3])
    except Exception as e:
        print("Error with data")
        print(rawdata)
        print(e)

while True:
    pub()
    time.sleep(5)
