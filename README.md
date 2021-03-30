# Environmental Monitor

* [Environmental Monitor](#environmental-monitor)
  * [Data captured](#data-captured)
  * [Sensors](#sensors)
  * [Dependencies](#dependencies)
    * [Python version](#python-version)
    * [Arduino](#arduino)
      * [Config](#config)
  * [Publishing to MQTT](#publishing-to-mqtt)
  * [Add as sensors to Home Assistant](#add-as-sensors-to-home-assistant)
    * [q](#q)
    * [python](#python)
  * [Adding sensors to Lovelace Dashboard](#adding-sensors-to-lovelace-dashboard)

## Data captured

Data is published to serial bus once per second as a comma delimited string.

Example:

```csv
26.70,35,736,1013,-5.91,26421
```

* Temperature - Celsius
* Humidity - Percent
* Light - Analog value between 0 and 100
* Pressure - Pa
* Altitude  - m (Not accurate)
* CRC-16 - checksum of data fields

## Sensors

* DHT11 - temperature + humidity
* BMP085 - temperature + pressure
* LDR - light

## Dependencies

### Python version

```bash
pip3 install -r requirements.txt
```

### Arduino

* [DHT sensor library](https://github.com/adafruit/DHT-sensor-library)
* [Adafruit BMP085 Unified](https://github.com/adafruit/Adafruit_BMP085_Unified)

#### Config

* Serial - `9600`
* LDR - `A0`
* DHT11 - `4`

## Publishing to MQTT

`serToMQTT.py` takes the data published by the Arduino and forwards it to an MQTT broker.

It takes the name of the serial port and name of the room it is in as parameters.

```bash
python3 serToMQTT.py "192.168.1.111" "/dev/ttyACM0" "livingroom"
```

An alternative to python is the q version `serToMQTT.q`

```bash
q serToMQTT.q -q "192.168.1.111" "/dev/ttyACM0" "livingroom"
```

You can subscribe from the command line to confirm your data is publishing to your broker:

```bash
mosquitto_sub -h 192.168.1.111 -t "homeassistant/#"
```

```bash
mosquitto_sub -h 192.168.1.111 -t "EnvironmentalMonitor/#"
```

## Add as sensors to Home Assistant

### q

[MQTT discovery](https://www.home-assistant.io/docs/mqtt/discovery/) will automatically add these sensors to Home Assistant for you.

### python

Discovery is not enabled, you will need to add to `configuration.yaml`:

```yaml
sensor:
  platform: mqtt
  name: "livingroomtemperature"
  state_topic: "EnvironmentalMonitor/livingroom/state"
  value_template: "{{ value_json.temperature }}"
  qos: 0
  unit_of_measurement: "ºC"

sensor 2:
  platform: mqtt
  name: "livingroomhumidity"
  state_topic: "EnvironmentalMonitor/livingroom/state"
  value_template: "{{ value_json.humidity }}"
  qos: 0
  unit_of_measurement: "%"

sensor 3:
  platform: mqtt
  name: "livingroompressure"
  state_topic: "EnvironmentalMonitor/livingroom/state"
  value_template: "{{ value_json.pressure }}"
  qos: 0
  unit_of_measurement: "hPa"

sensor 4:
  platform: mqtt
  name: "livingroomlight"
  icon: "mdi:white-balance-sunny"
  state_topic: "EnvironmentalMonitor/livingroom/state"
  value_template: "{{ value_json.light }}"
  qos: 0
  unit_of_measurement: "/100"
```

## Adding sensors to Lovelace Dashboard

To add to a Lovelace dashboard:

```yaml
entities:
  - entity: sensor.livingroomtemperature
  - entity: sensor.livingroomhumidity
  - entity: sensor.livingroompressure
  - entity: sensor.livingroomlight
show_icon: true
show_name: false
show_state: true
title: Living Room
type: glance
```
