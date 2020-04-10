# Environmental Monitor

## Data captured

Data is published to serial bus once per second as a comma delimited string.

Example:

```csv
27.20,35,602,1021,-66.64
```

* Temperature - Celsius
* Humidity - Percent
* Light - Analog value between 0 and 1023
* Pressure - Pa
* Altitude  - m (Not accurate)

## Sensors

* DHT11 - temperature + humidity
* BMP085 - temperature + pressure

# Config

* Serial - `9600`
* LDR - `A0`
* DHT11 - `4`
* BMP085 - `0x77`
