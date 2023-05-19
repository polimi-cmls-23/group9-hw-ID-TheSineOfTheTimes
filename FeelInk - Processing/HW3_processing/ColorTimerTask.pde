class ColorTimerTask extends TimerTask {
  public void run() {
    if(isAcceptingInputFromSensor){
      if (myPort.available() > 0){
        //svuotiamo il buffer
        //myPort.clear();
        println("READING");
        //read the string until '\n'
        data_string = myPort.readStringUntil(delimiter);
        if(data_string!= null){
          //split the string into single values
          data = data_string.split("\t"); 
          println(data[0]);
          c = color (Integer.parseInt(data[0]),Integer.parseInt(data[1]),Integer.parseInt(data[2]));
          
          //TODO: forse i valori hue sat e brightness non sono scalati correttamente
           push();
           colorMode(HSB,360,100,100);
           newEmotion((int)hue(c),(int)saturation(c),(int)brightness(c));
           println(hue(c));
           println(saturation(c));
           println(brightness(c));
           pop();
        }
        myPort.clear();
        isAcceptingInputFromSensor = false;
      }
    }
  }
}
