/*
FeelInk - An interactive audiovisual experience
Authors: Francesco Colotti, Gioele Fortugno, Matteo Gionfriddo, Emanuele Greco
*/

/*
General stuff:
OSC: listens on port 57001, sends on port 57000

SERIAL: you have to set your own serial port! Use Serial.list() to find the 
serial you want to use and then modify SELECTEDSERIAL

Press 's' when you want to use the sensor
*/

/*
TODOs:
-MDP implementation
*/

//import Processing Sound library
import processing.sound.*;
//import Processing Serial library
import processing.serial.*;

//import RiTA library
import rita.*;
import rita.antlr.*;
import com.google.gson.*;
import com.google.gson.stream.*;
import com.google.gson.reflect.*;
import com.google.gson.internal.*;
import com.google.gson.internal.reflect.*;
import com.google.gson.internal.bind.*;
import com.google.gson.internal.bind.util.*;
import com.google.gson.internal.sql.*;
import com.google.gson.annotations.*;
import org.unbescape.uri.*;
import org.unbescape.*;
import org.unbescape.javascript.*;
import org.unbescape.css.*;
import org.unbescape.xml.*;
import org.unbescape.java.*;
import org.unbescape.html.*;
import org.unbescape.csv.*;
import org.unbescape.json.*;
import org.unbescape.properties.*;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.misc.*;
import org.antlr.v4.runtime.tree.*;
import org.antlr.v4.runtime.tree.xpath.*;
import org.antlr.v4.runtime.tree.pattern.*;
import org.antlr.v4.runtime.dfa.*;
import org.antlr.v4.runtime.atn.*;

//OSC stuff
import oscP5.*;
import netP5.*;

//import  java.util for useful methods (though I'll try to use Processing alternatives if possible)
import java.util.*;
//import java.io.*; //commented since we're working with equivalent Processing methods for now

//MODIFY THESE ACCORDING TO YOUR GEAR
int BAUDRATE = 115200;
int SELECTEDSERIAL = 1;

//serial stuff
Serial myPort; // The serial port
char delimiter = '\n';
//Da spostare in color timer task
public String data_string = null;
public String[] data = null;
public color c;

RiTa r;
RiMarkov rm;
String txt;
String[] sentences;

//keeps track on when to change sentences
public Timer timer;
SentenceChangeTimerTask timerTask;
ColorTimerTask colorTask;

int delay = 8000; //time in milliseconds that a sentence is up
float xstart = random(10);
float xnoise = xstart;
float ynoise = random(10);
Dot[] centers;
int nDots = 100;
PNTriangle[] triangles;

String state = "HAPPY";
public color[] palette; //update to keep track of state

//audio stuff
FFT fft;
AudioIn in;
public int bands = 32;
public float[] spectrum = new float[bands];
//load the test audio file
SoundFile file;

//OSC stuff
OscP5 oscP5;
NetAddress myRemoteLocation;

//Emotion Mapper
EmotionMapper emoMap; //perché dio caro non si può fare 120 righe con >30 if/else if


void setup() {
  fullScreen();
  frameRate(60);
  //size(800,800);
  //open /data/palette_STATE.txt
  String fileName = "palette_" +state;
  String[] palette_lines = loadStrings(fileName+".txt");
  //each line is a color, insert it in the palette array
  colorMode(HSB, 360, 100, 100);
  palette = new color[20];
  for (int i = 0; i < 3; i++) {
    String[] rgb = split(palette_lines[i], ',');
    palette[i] = color(Integer.parseInt(rgb[0]), Integer.parseInt(rgb[1]), Integer.parseInt(rgb[2]));
  }
  println(palette[2]);
  //add 17 more colors to the palette
  //the colors need to be close to the ones already in the array
  //close being defined as a small difference in hue, saturation and brightness
  //the difference in hue should be less than 10
  //the difference in saturation should be less than 10
  //the difference in brightness should be less than 10
  for(int i = 3; i<20; i++){
    int j = floor(random(3));
    int h = floor(random(20));
    int s = floor(random(20));
    int b = floor(random(20));
    float h1 = hue(palette[j]);
    float s1 = saturation(palette[j]);
    float b1 = brightness(palette[j]);
    int h2 = (int)(h1 + h)%360;
    int s2 = (int)(s1 + s)%100;
    int b2 = (int)(b1 + b)%100;
    if(b2<30){
      b2+=30;
    }
    palette[i] = color(h2,s2,b2);
  }
  
  emoMap = new EmotionMapper();

  String[] lines = loadStrings("lines_"+state+".txt");
  txt = String.join(" ", lines);
  String[] testRita = RiTa.sentences(txt);
  //r = new RiTa();
  for (int i = 0; i< testRita.length;i++){
    println(testRita[i]);
  }
  rm = RiTa.markov(3);
  rm.addText(testRita);
  sentences = rm.generate(20);
  
  //we use a timer from java.util to keep track of when to change sentence and fetch color
  timer = new Timer();
  timerTask = new SentenceChangeTimerTask();
  colorTask = new ColorTimerTask();
  //schedule the timer task to run after a specified delay
  timer.schedule(timerTask, delay, delay); //the second "delay" is just the period between repeated calls
  timer.schedule(colorTask,1000,1000);
  /*
  for (int i = 0; i< sentences.length;i++){
    println(sentences[i]);
  }
  */
  println("---------------");
   centers = new Dot[nDots];
   for (int i = 0; i < nDots; i++) {
     centers[i] = new Dot();
   }
   triangles = new PNTriangle[floor(nDots/3)];
    for (int i = 0; i < triangles.length; i++ ){
      triangles[i] = new PNTriangle(centers[3*i],centers[3*i+1],centers[3*i+2]);
    }
    
    
  //osc stuff
  oscP5 = new OscP5(this,57001); // ascolta messaggi
  myRemoteLocation = new NetAddress("127.0.0.1",57000);//send messages locally
    
    
  // Create an Input stream which is routed into the Amplitude analyzer
  file = new SoundFile(this, "test_file.wav");
  fft = new FFT(this, bands);
  in = new AudioIn(this, 0);
  
  // start the Audio Input
  in.start();
  
  //file.play();
  //file.loop();
  // patch the AudioIn
  Sound s = new Sound(this);
  String[] devs = Sound.list();
  int devToSelect = -1;
  for(int i = 0; i<devs.length;i++){
    println(devs[i]);
    if(devs[i].contains("CABLE Output")){
      devToSelect = i;
    };
  }
  if(devToSelect==-1){
    println("A virtual audio cable (https://vb-audio.com/Cable/) is required to run this application.");
    System.exit(1);
  }
  s.inputDevice(devToSelect);
  fft.input(in);
  in.play();
  //variable to select the port
  myPort = new Serial(this, Serial.list()[SELECTEDSERIAL], BAUDRATE);
  
  //we need to start from happy!
  OscMessage myMessage = new OscMessage("/x");
  myMessage.add(1); //content
  oscP5.send(myMessage, myRemoteLocation); // invia il messaggio
  println("Startup msg sent");
  
}
//int px = 10;
//int py = 10;
public float t = 0; //"clock" for looping the animations

void draw() {
  //background(118,59,84);
  push();
  colorMode(RGB,255,255,255);
  fill(12);
  rect(0,0,width,height);
  pop();
  fft.analyze(spectrum);
  //t = t + 0.1;
  t++;
  //println(t);
  if(t==360){
    t = 0;
  }

  for (int i = 0; i < triangles.length; i++) {
    //println(triangles[i]);
    triangles[i].show();
    triangles[i].update();
  }
  /*
  //use this as an epic demonstration of low FPS
  stroke(40,0,100);
  ellipse(px,py,10,10);
  px++;
  py++;
  */
  displayCurrentState();
}
int prevFrame = -1;
int currSentence = 0;
//textbox stuff
float currSentenceX = 220;
float currSentenceY = 220;
int textBoxWidth = 360;
int textBoxHeight = 200;
void displayCurrentState(){
  push();
  colorMode(RGB,255,255,255);
  
  //we want text to be highlighted in white
  textSize(24);
  //try to guess the text size
  float tw = textWidth(sentences[currSentence]);
  float th = textAscent() + textDescent();
  float x = currSentenceX;// - tw/2;
  float y = currSentenceY;// - th/2;
  //this is just being extra generous with the guess, otherwise the white box will
  //be to small for the text, ruining everything
  //Yes, there would be better solutions
  //Yes, we don't have time so we're doing this
  int textLines = ceil(tw / (textBoxWidth-50))+1;
  fill(255);
  rect(x-10,y-th/2,textBoxWidth+20,th*textLines+th);

  stroke(12);  
  strokeWeight(2);
  fill(12);
  
  text(sentences[currSentence],currSentenceX,currSentenceY,textBoxWidth, textBoxHeight);
  
  //1st idea for visualisation
  /*
  colorMode(RGB,255,255,255);
  stroke(12);
  strokeWeight(2);
  fill(120);
  rect(width-400,height-250,400,250);
  //display the current state
  fill(255);
  textSize(20);
  text("Current State: " + state,width-380,height-220);
  //display a random thought from sentences
  //println(frameCount);
  
  textSize(15);
  text(sentences[currSentence],width-380,height-200,360, 150);
  */
  pop();
}
void updateCurrSentence(){
 currSentence++;
 currSentence = currSentence % sentences.length;

  currSentenceX = ceil(random(100,(width-1.5*textBoxWidth)));
  currSentenceY = ceil(random(100,(height-2*textBoxHeight))); 
}


public boolean isAcceptingInputFromSensor = false;

void mousePressed() {
  /*//UNCOMMENT THIS IF YOU WANT TO TEST WITHOUT THE ARDUINO
  for (int i = 0; i < triangles.length; i++) {
    //println(triangles[i]);
    triangles[i].changeVertexPositions();
  }
  
  //send OSC message
  OscMessage myMessage = new OscMessage("/x"); //label
  myMessage.add(int(random(1,7))); //content
  oscP5.send(myMessage, myRemoteLocation); // invia il messaggio
  println("msg sent");
  */
}


void keyPressed(){
  //for now we'll change "emotions" using keys
  if(key=='1'){
    changeState("HAPPY");
  }
  else if(key=='2'){
    changeState("SAD");
  }
  else if(key=='3'){
    changeState("FURIOUS");
  }
  else if(key=='4'){
    changeState("CALM");
  }
  
  if(key=='s'){
    isAcceptingInputFromSensor=!isAcceptingInputFromSensor;
  }
}

/*
Timer timerTransition = new Timer(); //We don't want a new input to trigger a change of state
//while the state is still changing (transition). We use a timer to prevent that together with a boolean
TransitionTimerTask transitionTask = new TransitionTimerTask();
*/

public boolean isChangingState = false;
void changeState(String newState){
  if(state==newState || isChangingState)
    return;
  isChangingState = true;
  state = newState;
    String fileName = "palette_" +state;
    String[] palette_lines = loadStrings(fileName+".txt");
    //each line is a color, insert it in the palette array
    colorMode(HSB, 360, 100, 100);
    palette = new color[20];
    for (int i = 0; i < 3; i++) {
      String[] rgb = split(palette_lines[i], ',');
      palette[i] = color(Integer.parseInt(rgb[0]), Integer.parseInt(rgb[1]), Integer.parseInt(rgb[2]));
    }
  for(int i = 3; i<20; i++){
    int j = floor(random(3));
    int h = floor(random(40));
    int s = floor(random(30));
    int b = floor(random(50));
    float h1 = hue(palette[j]);
    float s1 = saturation(palette[j]);
    float b1 = brightness(palette[j]);
    int h2 = (int)(h1 + h)%360;
    int s2 = (int)(s1 + s)%100;
    int b2 = (int)(b1 + b)%100;
    if(b2<30){
      b2+=30;
    }
    palette[i] = color(h2,s2,b2);
  }

  String[] lines = loadStrings("lines_"+state+".txt");
  txt = String.join(" ", lines);
  
  //r = new RiTa();

  rm = RiTa.markov(3);
  rm.addText(txt);
  currSentence = 0;
  try{
  sentences = rm.generate(20);
  }catch(RiTaException e){
    sentences = RiTa.sentences(txt);
  }
  //rita tends to bug a lot, forming sometimes huge arrays as outputs by splitting the sentences. 
  if(sentences[0].length() < 10){
    sentences = RiTa.sentences(txt);
  }
  /*
  for(int i = 0;i<20;i++){
    println(sentences[i]);
  }
  */
  
  for(int i = 0; i< triangles.length;i++){
    triangles[i].updateColor();
  }
  
  //send OSC message
  OscMessage myMessage = new OscMessage("/x"); //label
  //1 = happy, 2 = calm, 3 = sad, 4 furious
  int emo = 1;
  if(state.equals("CALM")){
    emo = 2;
  }else if(state.equals("SAD")){
    emo = 3;
  }else if(state.equals("FURIOUS")){
    emo = 4;
  }
  
  myMessage.add(emo); //content
  oscP5.send(myMessage, myRemoteLocation); // invia il messaggio
  println("msg sent");
  
  for (int i = 0; i < triangles.length; i++) {
    //println(triangles[i]);
    triangles[i].changeVertexPositions();
  }
  isChangingState = false;
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
}


// Function called every time a new emotion message arrives from Arduino
void newEmotion(int hue, int sat, int val){
  String emotion;
  // If True -> check Hue for getting the right color
  // If False -> It's Black, White or Gray -> check Value for getting the right between the three
  if ((sat > 20) && (val > 43)){
    emotion = emoMap.findEmotion(hue,0);
  }
  else{
    emotion = emoMap.findEmotion(val,1);
  }
  println(emotion);
  //this could happen and right now there is no faster fix
  if(emotion==null){
    emotion="FURIOUS";
  }
  changeState(emotion);
  
}
