# Environmental Monitor

## Data captured

Data is published to serial bus once per second as a comma delimited string.

Example:

```csv
26.70,35,736,1013,-5.91,26421
```

* Temperature - Celsius
* Humidity - Percent
* Light - Analog value between 0 and 1023
* Pressure - Pa
* Altitude  - m (Not accurate)
* CRC-16 - checksum of data fields

## Sensors

* DHT11 - temperature + humidity
* BMP085 - temperature + pressure
* LDR - light

## Dependencies

```bash
pip3 install paho-mqtt pyserial crcmod
```

## Config

* Serial - `9600`
* LDR - `A0`
* DHT11 - `4`
* BMP085 - `0x77`

## Publishing to MQTT

`serToMQTT.py` takes the data published by the Arduino and forwards it to an MQTT broker.

It takes the name of the serial port and name of the room it is in as parameters.

```bash
python3 serToMQTT.py "192.168.1.111" "/dev/ttyACM0" "livingroom"
```

You can subscribe from the command line to confirm your data is publishing to your broker:

```bash
mosquitto_sub -h 192.168.1.111 -t "hassio/#"
```
