# FeelInk
## An interactive audiovisual experience
The idea of the project is to create an audiovisual experience in which the user gets in touch with emotions. We looked for studies that associated colors with moods, and through the use of an RGB sensor we are able to capture the data that represents a color. So we have created soundscapes that can evoke emotions such as: happiness, sadness, relaxation, fear, love and related animation. The user detects a color with the sensor then associated audio and video will start.

# Requirements
* An Arduino or an ESP32 board (we used an Arduino Uno and an ESP32-Cam during development) or any board, really
* TCS34725 RGB Color Sensor
* A button
* Processing **4**. This is pretty important as we had issues with out-of-the-box Processing 3.x.x, even with the correct libraries installed
* **A virtual audio cable (in particular, we're using https://vb-audio.com/Cable/)**

For the ESP32-Cam code (Arduino IDE is used as a reference):
* Adafruit BusIO by Adafruit
* Adafruit TCS34725 by Adafruit

For the Arduino UNO code :
* DFRobot_TCS34725 by DFRobot

For the Processing code (Processing 4 is used as a reference), the following libraries are required:
* oscP5
* RiTA

For the SuperCollider code:
* [sc3plugins](https://supercollider.github.io/sc3-plugins/)

These are all downloadable directly from inside Processing (Sketch>Import Library...>Manage Libraries...).

Note that a correct configuration of the Arduino IDE is required in order to use an ESP32 board (we followed [this guide](https://randomnerdtutorials.com/installing-the-esp32-board-in-arduino-ide-mac-and-linux-instructions/)).

# User Guide (audio-visual side only)

1) Set your usual speaker device as the audio output.
2) Open the SuperCollider file and follows the guidelines in the comment section at the beginning of the file. Make sure to set as output device "CABLE Input"!
3) Open the main Processing file, be sure the audio input buffer as "CABLE Output" (if you're using VB Audio Cable this is automatic) and then run the code.
4) Press 's' (with the Processing sketch focused) when you want to use the sensor to read a color.
Enjoy!

# Video presentation
COMING SOON
