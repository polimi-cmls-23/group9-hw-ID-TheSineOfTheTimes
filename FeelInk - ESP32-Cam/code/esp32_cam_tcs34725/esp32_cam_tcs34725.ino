#include <Wire.h>
#include "Arduino.h"
#include "Adafruit_TCS34725.h"

/*
Code made to use the ESP32-Cam with the TCS34725 Sensor and a button
CMLSHW3-TheSineOfTheTimes
*/

// -----------------I2C-----------------
//needed since SDA and SCL are already used by the camera
#define I2C_SDA 14 // SDA Connected to GPIO 14
#define I2C_SCL 15 // SCL Connected to GPIO 15
/* 
Connect SCL    to analog 15
Connect SDA    to analog 14
Connect VDD    to 3.3V DC
Connect GROUND to common ground 
*/


const int buttonPin = 16;
TwoWire I2CSensors = TwoWire(0);

// our RGB -> eye-recognized gamma color
byte gammatable[256];

/* Initialise with specific int time and gain values */
Adafruit_TCS34725 tcs = Adafruit_TCS34725(TCS34725_INTEGRATIONTIME_50MS, TCS34725_GAIN_60X);

void setup(void) {
  Serial.begin(115200);
  I2CSensors.begin(I2C_SDA, I2C_SCL, 10000);
  if (tcs.begin(0x29, &I2CSensors)) {
    Serial.println("Found sensor");
  } else {
    Serial.println("No TCS34725 found ... check your connections");
    while (1);
  }

  //fill gamma table
  for (int i=0; i<256; i++) {
    float x = i;
    x /= 255;
    x = pow(x, 2.5);
    x *= 255;
      
    gammatable[i] = x;      
    //Serial.println(gammatable[i]);
  }

  pinMode(buttonPin, INPUT);

  
}


void loop(void) {
  /*
  RGB Color sensor stuff
  */
  uint16_t red, green, blue, clear, colorTemp, lux;
  float rRGB, gRGB, bRGB;
  tcs.getRawData(&red, &green, &blue, &clear);
  tcs.getRGB(&rRGB, &gRGB, &bRGB);
 
  Serial.print((int)rRGB);
  Serial.print('\t'); 
  //Serial.print("G:");
  Serial.print((int)gRGB);
  Serial.print('\t');
  //Serial:.print("B:");
  Serial.print((int)bRGB);
  Serial.print('\t'); 
  Serial.print('\n');
  
  delay(500);
}
