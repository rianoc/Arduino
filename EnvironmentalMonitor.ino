//Humidity
#include "DHT.h"
#define DHTPIN 4
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);

//Checksum
#include <util/crc16.h>

//Light
int LDR_Pin = A0; //analog pin 0

//Temperature, pressure & altitude
#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BMP085_U.h>
   
Adafruit_BMP085_Unified bmp = Adafruit_BMP085_Unified(10085);

void setup(void)
{
  Serial.begin(9600);
  dht.begin();
  bmp.begin();
}

void loop(void)
{
  sendTick();
  delay(1000);
}
//-------------------------------------------------------------

uint16_t calcCRC(char* str)
{
  uint16_t crc=0; // starting value as you like, must be the same before each calculation
  for (int i=0;i<strlen(str);i++) // for each character in the string
  {
    crc= _crc16_update (crc, str[i]); // update the crc value
  }
  return crc;
}

 void sendTick() {
 //Humidity
 int humidity = dht.readHumidity();

 //Light
 int lcurr = analogRead(LDR_Pin);
 lcurr = floor(lcurr/10.23);

 //Pressure
 sensors_event_t event;
 bmp.getEvent(&event);
 int pressure = event.pressure;
 float temperature;
 bmp.getTemperature(&temperature);
 float seaLevelPressure = SENSORS_PRESSURE_SEALEVELHPA;
 int altitude = bmp.pressureToAltitude(seaLevelPressure,event.pressure,temperature);

 //Send tick
 String serString= (String(temperature)+ "," +String(humidity) + "," +String(lcurr)+ "," +String(pressure)+ "," +String(altitude));
 int str_len = serString.length() + 1; 
 char char_array[str_len];
 serString.toCharArray(char_array, str_len);
 Serial.println(serString + "," + String(calcCRC(char_array)));
 Serial.flush();
}
