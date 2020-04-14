import paho.mqtt.client as mqttClient
import time
import serial
import sys

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("Connected to broker")
        global Connected
        Connected = True
    else:
        print("Connection failed")

Connected = False
broker_address= "192.168.1.106"
port = 1883
COM = sys.argv[1]
room = sys.argv[2]

client = mqttClient.Client()
client.on_connect= on_connect
client.connect(broker_address, port=port)
client.loop_start()

ser = serial.Serial(COM)

def pub():
    data = ser.readline()
    try:
     data = data.decode().strip()
    except:
        print("Failed to decode message")
        print(data)
        return
    if data[0] == "|" and data[-1] == "|":
        data = data[1:-1].split(',')
        data = list(map(float, data))
        client.publish("home-assistant/"+room+"/temperature",data[0])
        client.publish("home-assistant/"+room+"/humidity",data[1])
        client.publish("home-assistant/"+room+"/light",data[2])
        client.publish("home-assistant/"+room+"/pressure",data[3])
    else:
        print("Incomplete message")
        print(data)

while True:
    pub()
    time.sleep(5)