class TextField{
  String letters = "";
  int xP;
  int yP;
  int xS;
  int yS;
  boolean pressed = false; // True when the mouse is over and pressed
  Control c;
 
 
  TextField(String ltrs,int xPos,int yPos,int xSize, int ySize, Control c){
    letters = ltrs;
    xP = xPos;
    yP = yPos;
    xS = xSize;
    yS = ySize;
    this.c = c;
    
  }
 
  void textInput(String newCharacter){
    
    if(letters.length() == 4){
      c.processNumber(letters);
      letters = "";
      println("Should do something. Have five things");
    } else if(letters.length() > 4){
      c.processNumber(letters);
      letters = "";
      println("We should not have more than this number of things in dialMode");
      
    }
    
    
    
    
    if (newCharacter !=null && newCharacter != "DELETE" && newCharacter != "DECIMAL"){
      letters = letters + newCharacter;
      println(letters);
    }
    if (newCharacter !=null && newCharacter == "DELETE"){
      if (letters.length() >0){
        letters = letters.substring(0, letters.length()-1);
        println(letters);
      }
    }
    if (newCharacter == "DECIMAL"){
      if (letters.indexOf(".") == -1){// check to see if string already has a decimal in it
      letters = letters + ".";// if it doesn't then add one.
      println(letters);
      }
    }
 
 
 
  }
 
  void display() {
    stroke(0);
    fill(0);
    //rect(xP, yP, xS, yS);
    fill(255);
    textAlign(RIGHT);
    text(letters,xP+xS,yP+yS/1.5);
  }
 
}
