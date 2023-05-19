class Dot{
 public Dot(){
   //constructor
   //choose two random coordinates for the point
  this.x = random(1,width-1);
  this.y = random(1,height-1);
  this.xc = this.x;
  this.yc = this.y;
  this.r = 20;
  float randomValX = random(-1,1);
  float randomValY = random(-1,1);
  this.uniquenessFactorX = (randomValX/abs(randomValX));
  this.uniquenessFactorY = (randomValY/abs(randomValY));
  this.offFactor = 0;
  //for a color we start with a purple
  //set color mode as HSB
  //the first number is in degrees, the rest in percentage
  this.c = color(269, 38, 100);
  this.haloColorDir = -1;
  this.haloColor = color(hue(c), saturation(c) -20, brightness(c) + 20*haloColorDir);
  this.haloLerpVal = 0;
  //each dot will latch onto a FFT target band and follow it
  this.targetBand = floor(random(10,bands));
  this.lastArgX = 0;
  this.lastArgY = 0;
 }
 void show(){
    //draw the point
    push();
    //stroke(this.c);
    //strokeWeight(1);
    //point(this.x, this.y);
    noStroke();
    fill(this.haloColor);
    ellipse(this.x,this.y,10,10);
    
    /* //use this if you wish to test halo colors
    fill(this.haloColor);
    ellipse(20,20,200,200);
    */
    
    fill(this.c);
    ellipse(this.x,this.y,5,5);
    pop();
 }
 void updateColor(color cl){
   this.c = cl;
 }
 
 void update(){
  //update x and y following a cosine fashion
  //the x coordinate is updated by a cosine function
  //the y coordinate is updated by a sine function
  offFactor = min(lerp(offFactor, spectrum[this.targetBand]*50,0.1),50);
  xc = xc + offFactor * uniquenessFactorX;
  yc = yc + offFactor  * uniquenessFactorY;
  float argX,argY;
  
  argX = lerp(lastArgX, uniquenessFactorX*t + offFactor,0.5);
  argY = lerp(lastArgY, uniquenessFactorY*t + offFactor,0.5);
  x = xc; //+ uniquenessFactorX*(r +offFactor); //*cos(argX);   //the commented part doesn't make sense anymore TODO delete this
  y = yc; //+ uniquenessFactorY*(r + offFactor); //*sin(argY);
  if(xc>=width || xc<=0){
    uniquenessFactorX*=-1;
  }
  if(yc>=height || yc<=0){
    uniquenessFactorY*=-1;
  }
  //ellipse(xc,yc,10,10); //for testing
  lastArgX = argX;
  lastArgY = argY;
  
  updateHaloColor();
  if(updatingPos){
    updatePos();
  }
 }
 void updateHaloColor(){
   float val = lerp(brightness(c) + 40*haloColorDir, brightness(c) - 40*haloColorDir, haloLerpVal);
   haloLerpVal+=0.025;
   if(haloLerpVal>=1){
     this.haloColorDir *=-1;
     this.haloLerpVal = 0;
   }
   this.haloColor = color(hue(c), saturation(c) -20, val);
 }
 
 void updatePos(){
   xc = lerp(originalXC,targetX,updatingFactor);
   yc = lerp(originalYC,targetY,updatingFactor);
   updatingFactor += 0.009;
   if(updatingFactor>=1){
     updatingFactor = 0;
     updatingPos = false;
     float randomValX = random(-1,1);
     float randomValY = random(-1,1);
     this.uniquenessFactorX = (randomValX/abs(randomValX));
     this.uniquenessFactorY = (randomValY/abs(randomValY));
   }
 }
 
 void changePos(float newX,float newY){
  this.targetX = newX;
  this.targetY = newY;
  this.originalXC = this.xc;
  this.originalYC = this.yc;
  this.updatingPos = true;
 }
 void changePos(){
  this.targetX = random(1,width - 1);
  this.targetY = random(1,height - 1);
  this.originalXC = this.xc;
  this.originalYC = this.yc;
  this.updatingPos = true;
 }
 String toString(){
    return "(" + this.x + ", " + this.y + ")";
 }
 boolean updatingPos = false;
 float updatingFactor = 0;
 
 float x,y,r;
 float xc,yc;
 float targetX,targetY;
 float originalXC,originalYC;
 float offFactor,lastArgX,lastArgY;
 float uniquenessFactorX,uniquenessFactorY;
 int targetBand;
 color c;
 
 
 color haloColor;
 int haloColorDir;
 float haloLerpVal;
}
