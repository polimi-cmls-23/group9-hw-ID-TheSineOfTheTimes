#include <DFRobot_TCS34725.h>

DFRobot_TCS34725 tcs = DFRobot_TCS34725(&Wire, TCS34725_ADDRESS,TCS34725_INTEGRATIONTIME_50MS, TCS34725_GAIN_1X);
int MAX_CHANNEL_VALUE=500;

int inputPin = 12;
void setup() 
{
  //initizalize builtin pin
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(inputPin, INPUT);     // declare pushbutton as input
  
  bool builtin_led = HIGH;
  
  Serial.begin(115200);
  //Serial.println("Color View Test!");

  digitalWrite(LED_BUILTIN, builtin_led);
  
  
  while(!tcs.begin())
  {
    if(builtin_led ==HIGH){
      builtin_led=LOW;
    }
    else{
      builtin_led=HIGH;

    }
    digitalWrite(LED_BUILTIN, builtin_led);

    Serial.println("No TCS34725 found ... check your connections");
    delay(1000);
  }
}

  //Il codice funziona seguendo il grafico in
  //https://wiki.dfrobot.com/TCS34725_I2C_Color_Sensor_For_Arduino_SKU__SEN0212
  
void loop() {
  //tcs.setGain(TCS34725_GAIN_1X);
  //parte del bottone
  int val = digitalRead(inputPin);  // read input value
    
  uint16_t clear, red, green, blue;
  tcs.getRGBC(&red, &green, &blue, &clear);
  // turn off LED
  tcs.lock();
  
  /*
  Serial.print("C:\t"); Serial.print(clear);
  Serial.print("\tR:\t"); Serial.print(red);
  Serial.print("\tG:\t"); Serial.print(green);
  Serial.print("\tB:\t"); Serial.print(blue);
  Serial.println("\t");
  */


  uint32_t sum = clear;
  float r, g, b;
 /* 
  //V1, codice trovato sul sito
  // Figure out some basic hex code for visualization
  r = red; r /= sum;
  g = green; g /= sum;
  b = blue; b /= sum;
  r *= 256; g *= 256; b *= 256;
 */
  //V2, codice di Fra
  float rat;
  r = red; g = green; b = blue; sum = r+g+b;
  /*
  if(sum > MAX_CHANNEL_VALUE*3){
    sum = MAX_CHANNEL_VALUE*3;
  }
*/
  //rat=sum/MAX_CHANNEL_VALUE*3;
  r /= sum; g /= sum; b /= sum;

  r *= 255; g *= 255; b *= 255;
  
  //stampiamo il valore del bottone
  if (val == HIGH) {            // check if the input is HIGH
    digitalWrite(LED_BUILTIN, LOW);  // turn LED OFF
    //Serial.print('T');
  } else {
    digitalWrite(LED_BUILTIN, HIGH); // turn LED ON
    //Serial.print('F');
  }

  
  //in questo caso stampiamo il valore in HEX del colore
  //Serial.print("R:");
  Serial.print((int)r);
  Serial.print('\t'); 
  //Serial.print("G:");
  Serial.print((int)g);
  Serial.print('\t');
  //Serial:.print("B:");
  Serial.print((int)b);
  Serial.print('\t'); 
  Serial.print('\n');
  
  //prova -> usare i valori raw presi da get RGBC
  //Serial.println("USIAMO I VALORI COMPLETI");
  //Serial.print((int)red,HEX); Serial.print((int)green, HEX); Serial.print((int)blue, HEX);
  //Serial.print('\n');
  
  delay(500);
  
}
