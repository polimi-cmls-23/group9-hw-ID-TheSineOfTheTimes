class PNTriangle{
  public PNTriangle(){
    //don't use this for now
  }
  public PNTriangle(Dot vertex1,Dot vertex2,Dot vertex3){
    v1 = vertex1;
    v2 = vertex2;
    v3 = vertex3;
    //choose a random color from the palette
    this.cl = palette[floor(random(20))];
    //update the dots color
    v1.updateColor((color)this.cl);
    v2.updateColor((color)this.cl);
    v3.updateColor((color)this.cl);
  }
  void show(){
    //draw the triangle
    push();
    noStroke();
    
    fill(this.cl,200);
    //triangle(v1.x,v1.y,v2.x,v2.y,v3.x,v3.y);
    
    colorMode(RGB,255,255,255);
    
    stroke(this.cl,80);
    strokeWeight(2);  
    line(v1.x,v1.y,v2.x,v2.y);
    line(v2.x,v2.y,v3.x,v3.y);
    
    pop();
    v1.show();
    v2.show();
    v3.show();
  }
  void updateColor(){
    //the palette has been changed,
    //update the color of the triangle
    this.colorFrom = this.cl;
    this.colorTo = palette[floor(random(20))];
    
    //update the color of the vertices
    v1.updateColor((color)this.cl);
    v2.updateColor((color)this.cl);
    v3.updateColor((color)this.cl);
    /*
    //let's do something funnier
    //so far we connect v1 to v2 and v2 to v3
    //let's switch things up when colors are updated
    //obs: given how things are organized, switching v1 and v3 does nothing in practice
    float randomVal = random(-1,1);
    if(randomVal<0){
      switchVertexes(0,1); //switch v1 and v2
    }else{
      switchVertexes(1,2); //switch v2 and v3
    }
    */
    isLerpingColor = true;
  }
  void switchVertexes(int a,int b){
    //there are many ways to do this more elegantly
    //...
    //but we don't have time
    Dot temp = v2;
    if (a==0 && b==1){
      v2 = v1;
      v1 = temp;
    }else{
      v2 = v3;
      v3 = temp;
    }
  }
  void updateColorLerp(){
    this.cl = lerpColor(colorFrom,colorTo,lerpAmp);
    v1.updateColor((color)this.cl);
    v2.updateColor((color)this.cl);
    v3.updateColor((color)this.cl);
    
    lerpAmp +=0.01;
    if(lerpAmp>=1){
      lerpAmp = 0;
      isLerpingColor = false;
    }
  }
  
  void update(){
    v1.update();
    v2.update();
    v3.update();
    
    if(isLerpingColor){
      updateColorLerp();
    }
  }
  void changeVertexPositions(){
    //update the positions of the vertices
    v1.changePos();
    v2.changePos();
    v3.changePos();
  }
  void changeVertexPositions(float newX,float newY){
    //update the positions of the vertices
    v1.changePos(newX,newY);
    v2.changePos(newX,newY);
    v3.changePos(newX,newY);
  }
  String toString(){
    return "Triangle: (" + v1 +"; "+ v2+"; " + v3+")";
  }
  Dot v1,v2,v3;
  color cl;
  color colorFrom;
  color colorTo;
  float lerpAmp = 0;
  boolean isLerpingColor=false;
}
