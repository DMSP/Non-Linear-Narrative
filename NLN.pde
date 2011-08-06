import ddf.minim.*;
import proxml.*;
import oscP5.*;
import netP5.*;
import processing.video.*;
import java.util.UUID;
import java.awt.Desktop;


//Phone interface
int numOfButtons;
Button[] buttonsArray = new Button[1];//create the array class and add a new object to it
TextField textField1; // create a new textfield class
String letters = ""; // initial string for the text field.

//Defining classes, namespaces and globals
XMLInOut xmlIO;
OscP5 oscP5;
NetAddress myRemoteLocation;
proxml.XMLElement xml_areas;
Minim minim;
int rHN = 10000; //ReallyHighNumber - Just used where very many oportunities are needed.
Area murderArea;
Actor murderer;
PFont font;
String uniqueID; //Holder for unique identificator, used to log the number of players and time they play
int gameCount; // Count the number of turns the users play
Actor chargedSusp;
Area checkArea;
String resultText;


//Holders for game critical objects
Actor[] actors;
Area[][] areas;
Control c;
OSCSender oscS;
Analytics an;

// Variables for the textfeed
ArrayList textfeed;
int textfeedNr;
int turncounter;
int murdernum;

// Game mode switches
boolean simulationMode;
boolean videoMode;
boolean gameWindow;

// Global variables for interaction
String nettAddr = "localhost";
boolean officeMode = true;
boolean doorClicked;
boolean whiskeyClicked;
boolean radioClicked;
boolean phoneClicked;
boolean gunClicked;
boolean diceClicked; 
boolean magClicked;
boolean radioMode;
boolean phoneMode;
boolean investigateMode;
boolean endScreen;
boolean importantHolder;
boolean chargeSuspects;
boolean suspectChosen;
boolean winScreen;
boolean looseScreen;
String importantText;
String instructionText;
String chargeText;
boolean dialMode;
boolean fadeMode;
int fadeCounter;
int radioCounter;
int phoneCounter;
int buttonCounter;
int gunCounter;
int whiskyCounter;
int doorCounter;
int diceCounter;
int magCounter;


//Filter controllers
boolean main_filter;
boolean click_filter;
boolean map_filter;
boolean text_filter;
boolean bottom_filter;

//Tracks the number of times an object has been clicked
int phoneNum;
int radioNum;
int gunNum;
int doorNum;
int suspNum;
int gridNum;
int whiskeyNum;
int suspectsFound;
boolean neighbourTresh;
boolean whiskeyTresh;
boolean suspectTresh;
//Escape sequence EndScreen Statistics
boolean esc_ea;

//Sets variables, can be changed, but will cause lots of frustration
static boolean debugMode = false; //Turn on and off debug mode to find errors in progra
static int memorynum = 24; //Number of turns being memory of objects
static int gsx = 16; // Gridsize vertically 
static int gsy = 16; //Gridsize horisontally
static int numSusp = 5; //Numbers of Suspects __!! DO NOT CHANGE (automatic is not implemented in current version)
static int numVict = 3; //Numbers of Victims __ !! DO NOT CHANGE (automatic is not implemented in current version)


//Tempoary local solution for creating names -- Can be replaced with an XML tool
String[] victNames = new String[]{"Aunti","Oma","Granny"} ;
String[] suspNames = new String[]{"Trevor","Hugo","Christos","Marie","Mrs Rafferty"} ;
color[] suspTrace = new color[] { color(57,60,144,255),color(232,122,227,255),color(247,67,67,255),color(27,167,49,255),color(148,26,173,255) };
PImage[] suspPics;
PImage[] suspPics_lg;

//Click locations

int offsetX = 1030; //Ofset Map


//Phone

float x1 = 27;
float y1 = 303;
float w1 = 197;
float h1 = 147; 

//Radio

float x2 = 414;
float y2 = 273;
float w2 = 186;
float h2 = 103; 

//Door

float x3 = 507;
float y3 = 48;
float w3 = 236;
float h3 = 225; 

//Gun 
float x4 = 339; 
float y4 = 393;
float w4 = 374;
float h4 = 88;

//Whiskey
float x5 = 296;
float y5 = 112;
float w5 = 112;  
float h5 = 287;

//Magnifying Glass
float x6 = 715;
float y6 = 425;
float w6 = 125;
float h6 = 135;

//Dice
float x7 = 664; 
float y7 = 481;
float w7 = 43;
float h7 = 27;

//Important holder 
float ex1 = 140;
float ey1 = 50;
float eh1 = 750;
float ew1 = 300;

//DialFrame
float ex2 = 470;
float ey2 = 0; 
float eh2 = 288;
float ew2 = 288;





//Total size of gameframe
static int frameWidth = 1430;
static int frameHeight = 676;

//Holders for visual content
int backgroundCounter;
PImage[] backgrounds;
PImage[] phoneBackgrounds;
PImage[] gunBackgrounds;
PImage[] whiskyBackgrounds;
PImage[] doorBackgrounds;
PImage[] diceBackgrounds;
PImage[] magBackgrounds;
PImage gridVisited;
PImage gridUnvisited;
PImage radio; 
PImage phone;
PImage radioText;
PImage drawMap;
PImage nycMap;
PImage victim;
PImage eyes; 
PImage ears;
PImage microphones;
PImage textfeedholder;
PImage question;
PImage toolbar;

//Holders for various fontsizes / sets
PFont bigFont;
PFont mediumFont;
PFont smallFont;

/*
  Let the game begin
*/


void setup(){ 
  /*
  Loads the program
  */
  
//Sends signal to OS to open the max patch. Require runtime installed on users computer
try{
  String here = sketchPath("");
   Desktop.getDesktop().open(new File(here+"/data/NLN_AudioProg.mxf"));
  } catch(Exception e){
     println(e); 
  }
 
 
//loads the xml file for areas
xmlIO = new XMLInOut(this);
 try {
    xml_areas = xmlIO.loadElementFrom("data/areas.xml");
   //xmlIO.loadElement("data/actors.xml"); 
  } catch (Exception e) {
    println("UNABLE TO LOAD XML DATAFILES. WILL CRASH");
    exit();
  }
  
//Sets the modes and do startup thing
simulationMode = true;  //Starts in simulation mode

//Sets the click points to false - no one is clicking them
doorClicked = false;
radioClicked = false;
phoneClicked = false;
gunClicked = false;
whiskeyClicked = false;
doorClicked = false;
magClicked = false;
diceClicked = false;
radioMode = false;
phoneMode = false;
investigateMode = false;

//Sets the filters to false
main_filter = false;
map_filter = false;
text_filter = false;
bottom_filter = false;
click_filter = false;

//Set game action texts to empty and objects to null
instructionText = "";
chargeText = "";
resultText = "";
chargedSusp = null;
checkArea = null;

//Loads the possibiity to control textfeed with mousewheel
  addMouseWheelListener(new java.awt.event.MouseWheelListener() { 
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) { 
      mouseWheel(evt.getWheelRotation());
  }}); 


//Initialise sound network controller
oscS = new OSCSender(this);

   //Initialises the textfeed
 textfeed = new ArrayList(); textfeed.add("Welcome to the Non-linear Narrative. Please look around");
 textfeedNr = 0;
 
 // Loading game logic
 int turncounter = 0; //Reset the turn counter
 c = new Control();
 c.createAreas();
 c.createActors();
 
 //Initialise Analytic tools
 UUID tempUniqueID = UUID.randomUUID();
 uniqueID = String.valueOf(tempUniqueID);
 an = new Analytics();
 
 
  println("Gamelogic generated, loading content data");


  size(frameWidth,frameHeight);
  frameRate(10);

 // Reads backgrounds  
  backgrounds = new PImage[10];
  backgroundCounter = 0; 
  for(int i  = 0; i < 10; i++){
      backgrounds[i] = loadImage("data/backgrounds/bg"+(i+1)+".jpg"); 
  }
  
  gunCounter = 0;
  gunBackgrounds = new PImage[37];
  for(int i = 0; i < 37; i++){
     gunBackgrounds[i] = loadImage("data/backgrounds/gun"+(i+1)+".jpg"); 
  }
  
  suspPics = new PImage[5];
  for(int i  = 0; i < 5; i++){
      suspPics[i] = loadImage("data/susp"+(i+1)+".jpg"); 
  }
  
  suspPics_lg = new PImage[5];
   for(int i  = 0; i < 5; i++){
      suspPics_lg[i] = loadImage("data/susp"+(i+1)+"_lg.jpg"); 
  }
  
  whiskyBackgrounds = new PImage[19];
   for(int i  = 0; i < 19; i++){
     whiskyBackgrounds[i] = loadImage("data/backgrounds/Whisky"+(i+1)+".jpg"); 
  }
  
    diceBackgrounds = new PImage[38];
   for(int i  = 0; i < 38; i++){
     diceBackgrounds[i] = loadImage("data/backgrounds/Dice"+(i+1)+".jpg"); 
  }
  
    magBackgrounds = new PImage[19];
   for(int i  = 0; i < 19; i++){
     magBackgrounds[i] = loadImage("data/backgrounds/MAG"+(i+1)+".jpg"); 
  }
  
  toolbar = loadImage("data/toolbar.jpg");
 
  
  phoneBackgrounds = new PImage[20];
  phoneCounter = 0;
  for(int i = 0; i < phoneBackgrounds.length; i++){
     phoneBackgrounds[i] = loadImage("data/backgrounds/phone"+(i+1)+".jpg");
  }
 radioText = loadImage("data/Meanwhile.png");
 radio = loadImage("data/radio.jpg");
 phone = loadImage("data/phone.jpg");
 drawMap = loadImage("data/bgmapHand.jpg");
 ears = loadImage("data/ear.png");
 eyes = loadImage("data/eye.png");
 question = loadImage("data/question.jpg");
 textfeedholder = loadImage("data/textframe.jpg");
 gridVisited = loadImage("data/grid_visited.jpg");
 gridUnvisited = loadImage("data/grid_unvisited.jpg");
 
 //This is rather silly, but finds a random generated font -- Temporary, and here because of problems with intercompability of fonts
  String[] fontlist = PFont.list(); 
 font = createFont(fontlist[int(random(5))], 10);
 buttonCounter = 0;
 
// bigFont = loadFont("Type-Ra-16.vlw");
// mediumFont = loadFont("Type-Ra-14.vlw");
// smallFont = loadFont("Type-Ra-12.vlw");

print("Altering the last variables...");

//Sets number val
phoneNum = 0;
radioNum = 0; 
gunNum = 0;
doorNum = 0;
suspNum = 0;
gridNum = 0;
doorNum = 0;
whiskeyNum = 0;
fadeCounter = 0;

// Set analytic tresholds to false
neighbourTresh = false;
suspectTresh = false; 
whiskeyTresh = false;

// Sets last logic
chargeSuspects = false;
winScreen = false;
looseScreen = false;
dialMode = false;
fadeMode = false; 

//Escape sequence EndScreen Statistics
esc_ea = true;

  // Seeds the events
  c.runsimulation();
  
  // Starts game window
  gameWindow = true;
  
  println(".... and we are good to go!");
  
  smooth();

  // For phone method
  // Inputs: letters, xpos, ypos, xsize, ysize

  textField1 = new TextField("",500, 213-53*4,53*4,53*2,c);
   
  // Inputs: command, label, posX, posY, size, base color, over color, press color
  Button button1 = new Button("1","1", 477,224-53*2, 53, color(50), color(70), color(90));
  Button button2 = new Button("2","2",529, 224-53*2, 53,color(50), color(70), color(90));
  Button button3 = new Button("3","3",583, 224-53*2, 53,color(50), color(70), color(90));
  Button button4 = new Button("4","4",636, 224-53*2, 53,color(50), color(70), color(90));
  Button button5 = new Button("5","5",689, 224-53*2, 53,color(50), color(70), color(90));
  Button button6 = new Button("6","6",477, 224-53, 53,color(50), color(70), color(90));
  Button button7 = new Button("7","7",529, 224-53, 53,color(50), color(70), color(90));
  Button button8 = new Button("8","8",583, 224-53, 53,color(50), color(70), color(90));
  Button button9 = new Button("9","9",636, 224-53, 53,color(50), color(70), color(90));
  Button button0 = new Button("0","0",689, 224-53, 53,color(50), color(70), color(90));
  Button buttonDEL = new Button("DELETE","<",689, 224, 53,color(50), color(70), color(90));
  Button buttonDECIMAL = new Button("DECIMAL",".",477, 224, 53,color(50), color(70), color(90));
 
  // append the buttonsArray one at a time with each object
  buttonsArray = (Button[]) append(buttonsArray,button1);
  buttonsArray = (Button[]) append(buttonsArray,button2);
  buttonsArray = (Button[]) append(buttonsArray,button3);
  buttonsArray = (Button[]) append(buttonsArray,button4);
  buttonsArray = (Button[]) append(buttonsArray,button5);
  buttonsArray = (Button[]) append(buttonsArray,button6);
  buttonsArray = (Button[]) append(buttonsArray,button7);
  buttonsArray = (Button[]) append(buttonsArray,button8);
  buttonsArray = (Button[]) append(buttonsArray,button9);
  buttonsArray = (Button[]) append(buttonsArray,button0);
  buttonsArray = (Button[]) append(buttonsArray,buttonDEL);
  buttonsArray = (Button[]) append(buttonsArray,buttonDECIMAL);

}

void draw() {
  background(33);
  if(videoMode){
      background(0);
       videoMode = false; 
       textFont(font, 32);
       
       String openingText = "";
       
       //Get time of day and print appropriate introduction to the game
       int timeTest = c.getHour(0);
       if(timeTest<8){
         openingText = "While the city was sleeping";
       } else if(timeTest>=8 && timeTest < 16){
         openingText = "In the middle of the day";
       } else {
         openingText = "The end of a busy day";
       } 
       //Ask the sound controller to play intro
       fill(255);
       text(openingText,800,600);
       delay(10000); // Wait for 8 seconds. Sound playing, and text on screen
       oscS.sendMessage("gameStart");
       
       
       
  } else if(endScreen) {
    
    if(esc_ea){
     an.registerEndGame();
     link("http://nonlinearnarrative.org/endGame.php?gameID="+uniqueID, "_new"); 
    }
    
    esc_ea = false;
    
    background(0);
    textFont(font, 32);
    text(resultText,200,500);
    
    
  } else if(gameWindow) {
  fill(0);
  noStroke();
  
  //Draws the window structure
  rect(1024,0,6,frameHeight);
  rect(1030,400,400,6);
  rect(0,576,1024,6);
  //Places images
  image(drawMap,1030,0);
  image(textfeedholder,1030,406);
  //if(!investigateMode){
  image(toolbar,0, 582);
 // }
  
  // Plays appropriate background to action
  if (backgroundCounter == 10){backgroundCounter = 0;}
  image(backgrounds[backgroundCounter],0,0);
  backgroundCounter++;
 
  
  if(phoneClicked){
    if(phoneCounter == 19){phoneCounter = 0; phoneClicked = false;}
    image(phoneBackgrounds[phoneCounter],0,0);
    phoneCounter++;
  }
  
  if(gunClicked){
   if(gunCounter == 37){gunCounter = 0; gunClicked = false;}
   if(gunCounter == 22){ oscS.sendMessage("playGun");}
   image(gunBackgrounds[gunCounter],0,0);
   gunCounter++;
   } 
   
   
   if(whiskeyClicked){
   if(whiskyCounter == 17){whiskyCounter = 0; whiskeyClicked = false;}
    image(whiskyBackgrounds[whiskyCounter],0,0);
    println("WhiskeyNr: "+whiskyCounter);
     whiskyCounter++;
   }
   
   if(diceClicked){
      if(diceCounter == 38){diceCounter = 0; diceClicked = false;}
    image(diceBackgrounds[diceCounter],0,0);
    println("DiceNr: "+diceCounter);
     diceCounter++;
   }
   
   if(magClicked){
    if(magCounter == 18){magCounter = 0; magClicked = false;}
    image(magBackgrounds[magCounter],0,0);
    println("MagNr: "+magCounter);
     magCounter++;
     
     
   }
     
     
  
    
  // Draws the side panels
  
  if(radioMode){
    image(radio,750,0);
  }
  
  if(phoneMode){
    image(phone,750,0);
  }
    
    
  // Checks treshold and call updates
  
  if(!suspectTresh){
    int localTest = 0;
    for(int i = 0; i<numSusp; i++){
     if (actors[i].known){
       localTest++;
     }
    }
   if(localTest == 5 ){
     suspectTresh = true;
     oscS.sendMessage("foundSuspect");
     an.registerFoundSuspects();
   }
  }
  if(!whiskeyTresh){
   if(whiskeyNum == 5){
    an.registerGotDrunk();
    whiskeyTresh = true; 
   }
  }
 
  if(!neighbourTresh){
    if(gunNum == 3){
      an.registerScaredNeighbour();
      neighbourTresh = true;
    }
  }
  
  fill(0,255,0);
  textFont(font); 
  text(c.gettime(0),15,15);
  text(instructionText,100,15);
  fill(255);



//Draws the cardiographic image according to activity known in area  
if(investigateMode){
  for(int i = 0; i < 23; i++){
    boolean visitor = false;
    for(int j = 0; j< numSusp+numVict; j++){
      if(actors[j].memory[(turncounter-24)+i] == checkArea){visitor = true;}
    }
    if(visitor){
      image(gridVisited,30+(i*42),582);
    } else{
      image(gridUnvisited,30+(i*42),582);
    }
}
}
  
  for(int i= 0; i<numSusp; i++){
    fill(255);
    if(actors[i].known){
      fill(0,266,0);
      stroke(color(15));
    }
   if(actors[i].known) image(suspPics[i], 15, 20+62*i); 
  }
  noStroke();
  
  

     for(int i=0; i < gsx; i++){
      for(int j=0; j <gsy; j++){

        
        //Code under marks if microphones or cameras are in place
        Area a = areas[i][j];
        
        if(a.heard){
          fill(255,0,255,60);
          noStroke();
          rect(offsetX+i*25,j*25,25,25);
        }
        if(a.seen){
          fill(255,255,255,90);
          noStroke();
          rect(offsetX+i*25,j*25,25,25); 
        }
        
        if(a.mic == true){
          image(ears,offsetX+i*25,j*25,25,25);
        }
        if(a.cam == true){
        image(eyes,offsetX+i*25,j*25,25,25); 
        }
        
        if(a == checkArea){
          fill(0,0,255,100);
         rect(offsetX+i*25,j*25,25,25); 
          
        }

      }
     }
      fill(0,0,0);
     stroke(200,200,200);
     
     
     
     /*
     Textbox function. Fill the textbox with the last sentences from the textfeed and print them on to the screen
     */
     int textOffsetX = 1030 + 5 ;
     int textOffsetY = 406 + 20 ;
     int textspacing = 14 ;
      
      textFont(font);  
       textAlign(LEFT);
     for(int texti = 0; texti < 18; texti++){
       if(texti < textfeed.size()){
         String textstring;
         try {
         if(textfeed.size() > 18){
           
          textstring = textfeed.get((textfeed.size() - (texti +1) - textfeedNr)).toString();
         } else {
          textstring = textfeed.get((textfeed.size() - (texti +1) )).toString();
         }
         text(textstring,textOffsetX ,((textspacing*texti)+textOffsetY));
       
       } catch (Exception e){
         //Whoops
         }
       }
     }
     
    //Filter fuctions - To impose a new focal point for the player
  fill(0,0,0,150);
  if(main_filter) rect(0,0,1024,576);
  if(map_filter) rect(1030,0,400,400);
  if(text_filter) rect(1030,406,400,height-406);
  if(bottom_filter) rect(0,582,1024,height-582);
  if(click_filter) rect(0,0,1024-270,576);

  
           /*
             Important holder is the in screen interface which appears when all five suspects are found, and can be prosecuted.
           */
          if(importantHolder){  // Opens the imporantHolder and Halts game
            main_filter = true;
            map_filter = true;
            text_filter = true;
            bottom_filter = true;
            fill(33);
            rect(140,50,750,300);
  
                 if(chargeSuspects){
                    importantText = "Who is the murderer? ";
                    for(int i = 0; i<numSusp; i++){
                      image(suspPics_lg[i], 140+((i*150)), 60); 
                      fill(255);
                      
                      
                      text(importantText,150,230);
                      text(chargeText,150,260);
                      text(resultText,150,300);
                    }

                      } else {
                      //Should not be here
                      
                      }
          } else if(dialMode){
            rect(465,0,288,288);
 
  textField1.display();
   
  // loop through all the button objects and run update and display functions.
  for(int i=1; i<buttonsArray.length; i++){
    buttonsArray[i].update();
    buttonsArray[i].display();
  }
   
  noStroke();
  fill(50);
            
          } else {
            
           // do nothing 
          }
      

  } else {
    //Not here either
    
  }
  
  
  
} //End of method draw()


void mousePressed() {
        {
  // loop through ALL the objects and run press on buttons and return values for all buttons to textField object.
  for(int i=1; i<buttonsArray.length; i++){
    buttonsArray[i].press();
    textField1.textInput(buttonsArray[i].output());
  }
}


/* Holder to display text within the main frame */
  
 if(importantHolder){
   if(mouseButton == LEFT){
    if(mouseX>0 && mouseX<width && mouseY>0 && mouseY<height){ //Checks that click is within gameframe
       boolean inside = true;
       if(mouseX>140 && mouseX<140+750 && mouseY>50 && mouseY<50+300){
         inside = true;
       } else {
         inside = false; 
        }
        //If click is outside the frame. Goes back to game
        if(!inside){
        importantHolder = false;
        main_filter = false;
        map_filter = false;
        text_filter = false;
        bottom_filter = false;
        click_filter = false; 
        } else{
            int picOutsetX = 140;
            int picSize = 150;        
           
           if(mouseX>picOutsetX && mouseX<picOutsetX+picSize && mouseY>60 && mouseY < 60+picSize){          
            if(actors[0] == murderer && chargedSusp == actors[0]){ println("You nailed that bastard!"); oscS.sendMessage("solvedGame/right"); resultText = "You chose the right person. "+actors[0].name+" was the killer"; endScreen = true;
            } else if(actors[0] != murderer && chargedSusp == actors[0]){resultText = "You chose the wrong person. "+ murderer.name+" was the killer"; endScreen = true; oscS.sendMessage("solvedGame/wrong");} 
            chargeText = "You charged - Click to confirm: "+actors[0].name; oscS.sendMessage("phoneResult/confirm");
            chargedSusp = actors[0];
             
           } else if(mouseX>picOutsetX+picSize && mouseX<picOutsetX+(picSize*2) && mouseY>60 && mouseY < 60+picSize){
             if(actors[1] == murderer && chargedSusp == actors[1]){ println("You nailed that bastard!"); oscS.sendMessage("solvedGame/right"); resultText = "You chose the right person. "+actors[1].name+" was the killer"; endScreen = true;
             } else if(actors[1] != murderer && chargedSusp == actors[1]){resultText = "You chose the wrong person. "+ murderer.name+" was the killer"; endScreen = true; oscS.sendMessage("solvedGame/wrong");} 
             chargeText = "You charged - Click to confirm: "+actors[1].name; oscS.sendMessage("phoneResult/confirm");
             chargedSusp = actors[1];
             
             } else if(mouseX>picOutsetX+(picSize*2) && mouseX<picOutsetX+(picSize*3) && mouseY>60 && mouseY < 60+picSize){
               if(actors[2] == murderer && chargedSusp == actors[2]){ println("You nailed that bastard!"); oscS.sendMessage("solvedGame/right");resultText = "You chose the right person. "+actors[2].name+" was the killer"; endScreen = true;
               } else if(actors[2] != murderer && chargedSusp == actors[2]){resultText = "You chose the wrong person. "+ murderer.name+" was the killer"; endScreen = true; oscS.sendMessage("solvedGame/wrong");}  
               chargeText = "You charged - Click to confirm: "+actors[2].name; oscS.sendMessage("phoneResult/confirm");
               chargedSusp = actors[2];
               
               
             } else if(mouseX>picOutsetX+(picSize*3) && mouseX<picOutsetX+(picSize*4) && mouseY>60 && mouseY < 60+picSize){
               if(actors[3] == murderer && chargedSusp == actors[3]){ println("You nailed that bastard!"); oscS.sendMessage("solvedGame/right");resultText = "You chose the right person. "+actors[3].name+" was the killer"; endScreen = true;
             } else if(actors[3] != murderer && chargedSusp == actors[3]){resultText = "You chose the wrong person. "+ murderer.name+" was the killer"; endScreen = true; oscS.sendMessage("solvedGame/wrong");} 
               chargeText = "You charged - Click to confirm: "+actors[3].name; oscS.sendMessage("phoneResult/confirm");
               chargedSusp = actors[3];
               
             } else if(mouseX>picOutsetX+(picSize*4) && mouseX<picOutsetX+(picSize*5) && mouseY>60 && mouseY < 60+picSize){
               if(actors[4] == murderer && chargedSusp == actors[4]){ println("You nailed that bastard!"); oscS.sendMessage("solvedGame/right");resultText = "You chose the right person. "+actors[4].name+" was the killer"; endScreen = true;
             } else if(actors[4] != murderer && chargedSusp == actors[4]){resultText = "You chose the wrong person. "+ murderer.name+" was the killer"; endScreen = true; oscS.sendMessage("solvedGame/wrong");} 
               chargeText = "You charged - Click to confirm: "+actors[4].name; oscS.sendMessage("phoneResult/confirm");
               
           }
           
         
 
        }
    } 
   
 }
  
  //Shortcut version, so the user don't have to call the detective each time
} else if(dialMode){
  if(mouseButton == LEFT){
    if(mouseX>1030 && mouseX<1030+400 && mouseY>0 && mouseY<400){
     println("Shortcut clicked");
     dialMode = false;
     text_filter = false;
         
    }
    
    } 
    
} else {

          if(mouseButton == LEFT){
            
                //Functions are within the map sector            
              if(mouseX>offsetX && mouseX < offsetX+25*gsx && mouseY > 0 && mouseY < gsy*25){
                  if(radioMode) {
                       areas[(mouseX-offsetX)/25][mouseY/25].mic = true;
                       buttonCounter++;
                  } else if(phoneMode){
                      areas[(mouseX-offsetX)/25][mouseY/25].cam = true;
                      buttonCounter++;
                  } else if(investigateMode){
           
                   checkArea = areas[(mouseX-offsetX)/25][mouseY/25];
                  }
                        //Counts the number of clicks by the user. 5 flicks then reRunSimulation and clear tools
                      
                      if(buttonCounter > 5){
                            c.reRunSimulation();
                            gameCount++;
                            c.clearTools();
                            radioMode = false;
                            phoneMode = false;
                            main_filter = false;
                            text_filter = false;
                            bottom_filter = false;
                            click_filter = false;
                            buttonCounter = 0;
                }
                   //Functions are 
               } else if(mouseX>0 && mouseX<offsetX && mouseY>0 && mouseY <1024 && !click_filter){
   
   
                 if(mouseX>x1 && mouseX <x1+w1 && mouseY>y1 && mouseY <y1+h1){
                      println("The mouse is pressed and over the phone");
                      phoneClicked = true;
                      phoneMode = true;
                      dialMode = true;
                      click_filter =  true;
                      phoneNum++;
                      oscS.sendMessage("playPhone");
                      textfeed.add("___________***___________");                      
                      textfeed.add("Luigi's Pizza    : 9136 ");
                      textfeed.add("Informant        : 7824 ");
                      textfeed.add("My numbers:");
                      textfeed.add("___________***___________");
                  }
                   if(mouseX>x2 && mouseX <x2+w2 && mouseY>y2 && mouseY <y2+h2){
                          println("The mouse is pressed and over the radio");
                          radioClicked = true;
                          radioMode = true;
                          click_filter = true;
                          radioNum++;
                          oscS.sendMessage("playRadio");
                  }
                 if(mouseX>x3 && mouseX <x3+w3 && mouseY>y3 && mouseY <y3+h3){
                        println("The mouse is pressed and over the door");
                        if(suspectTresh){
                         doorClicked = true;
                         doorNum++;
                         oscS.sendMessage("playDoor");
                         importantHolder = true; 
                         main_filter = true;
                        chargeSuspects = true;
                    } else {
                     println("Not found aditional suspects yet");
                     oscS.sendMessage("notFoundEnoughSuspects"); 
                    }
      
      
                  }
                if(mouseX>x4 && mouseX <x4+w4 && mouseY>y4 && mouseY <y4+h4) {
                     println("Pang");
                     gunClicked = true;
                     gunNum++;

                }
                if(mouseX>x5 && mouseX <x5+w5 && mouseY>y5 && mouseY <y5+h5){
                    println("Glugg glugg");
                    whiskeyNum++;
                    whiskeyClicked = true;
                    oscS.sendMessage("playWhisky");
                }
                if(mouseX>x6 && mouseX <x6+w6 && mouseY>y6 && mouseY <y6+h6){
                  println("Glass is up!");
                  magClicked = true;
                  investigateMode = true;                  
                  main_filter = true;
                } else if(mouseX > 0 && mouseX < offsetX && mouseY > 0 && mouseY < 758 && investigateMode){
                     println("Someone clicked here - Should turn off investigation");
                     investigateMode = false;
                     main_filter = false; 
                     checkArea = null;
                }
                
                
                 if(mouseX>x7 && mouseX <x7+w7 && mouseY>y7 && mouseY <y7+h7){
                    println("Let's gamble");
                    diceCounter++;
                    diceClicked = true;
                    oscS.sendMessage("playDice");
                }
                
                
                
                

      }
      
      if(mouseX > 15 && mouseX < 75 && mouseY > 20 && mouseY < 310) { //Is within the supsect field
    
      int tempNum = floor(mouseY / 62);
      if(tempNum >= 0 && tempNum < 5){
      if(actors[tempNum].known){
        oscS.sendMessage("pokeSuspect"+(tempNum+1));
        
      }
    }
  }
    
                
    
               } //End of check Desk
 
               }//End of check mouse button
        //her


}//End of method



 	
void mouseMoved(){
  instructionText = "";
  cursor(POINT);

  
  
  if(importantHolder){
        boolean inside = true;
       if(mouseX>140 && mouseX<140+750 && mouseY>50 && mouseY<50+300){
         inside = true;
       } else {
         inside = false; 
        }
        if(inside) {
            int picOutsetX = 140;
            int picSize = 150;
            
           if(mouseX>picOutsetX && mouseX<picOutsetX+picSize && mouseY>60 && mouseY < 60+picSize){
             cursor(HAND);
             chargeText = (String)  actors[0].name;

 
             
           } else if(mouseX>picOutsetX+picSize && mouseX<picOutsetX+(picSize*2) && mouseY>60 && mouseY < 60+picSize){
             chargeText = (String) actors[1].name;
               cursor(HAND);
             
             } else if(mouseX>picOutsetX+(picSize*2) && mouseX<picOutsetX+(picSize*3) && mouseY>60 && mouseY < 60+picSize){
               chargeText = (String) actors[2].name;
               cursor(HAND);
               
             } else if(mouseX>picOutsetX+(picSize*3) && mouseX<picOutsetX+(picSize*4) && mouseY>60 && mouseY < 60+picSize){
               chargeText = (String) actors[3].name;
               cursor(HAND);
               
             } else if(mouseX>picOutsetX+(picSize*4) && mouseX<picOutsetX+(picSize*5) && mouseY>60 && mouseY < 60+picSize){
               chargeText = (String) actors[4].name;
               cursor(HAND);

               
           } 
           println(chargeText);
           
         
 
        }
    } else if(mouseX>offsetX && mouseX < offsetX+25*gsx && mouseY > 0 && mouseY < gsy*25){
        if(radioMode || phoneMode || investigateMode){
          cursor(HAND);
        } else {
          cursor(POINT);
        }

   
  } else if(mouseX > 15 && mouseX < 75 && mouseY > 20 && mouseY < 310) { //Is within the supsect field
    
    int tempNum = floor(mouseY / 62);
    if(tempNum >= 0 && tempNum < 5){
      if(actors[tempNum].known){
        cursor(HAND);
      instructionText = (String) actors[tempNum].name;
      }
    }
  }



      
        
    
    /*
      Displays text for objects that the user can interact wiht. Does also change the pointer into a hand    
    */
 if(mouseX>0 && mouseX<offsetX && mouseY>0 && mouseY <1024 && !click_filter){
   
   
                 if(mouseX>x1 && mouseX <x1+w1 && mouseY>y1 && mouseY <y1+h1){
                      instructionText = "Phone : Make a call";
                      cursor(HAND);
                    

                  }
                   if(mouseX>x2 && mouseX <x2+w2 && mouseY>y2 && mouseY <y2+h2){
                         instructionText = "Radio : Tune in on the cops";
                           cursor(HAND);
 
                  }
                 if(mouseX>x3 && mouseX <x3+w3 && mouseY>y3 && mouseY <y3+h3){
                   if(!suspectTresh){
                        instructionText = "Door : You have to gather more info";
                          cursor(HAND);
                   } else {
                        instructionText = "Door : Who do you want to charge?";
                          cursor(HAND);
                   }

      
                  }
                if(mouseX>x4 && mouseX <x4+w4 && mouseY>y4 && mouseY <y4+h4) {
                    instructionText = "Gun : What does your neighbour say?";
                      cursor(HAND);
    

                }
                if(mouseX>x5 && mouseX <x5+w5 && mouseY>y5 && mouseY <y5+h5){
                    instructionText = "Whisky : You never say no to a dram?";
                      cursor(HAND);

                }
                if (mouseX>x6 && mouseX <x6+w6 && mouseY>y6 && mouseY <y6+h6){
                  instructionText = "Magnifying glass : Investigate a tile";
                  cursor(HAND);
                }
                
                if (mouseX>x7 && mouseX <x7+w7 && mouseY>y7 && mouseY <y7+h7){
                  instructionText = "Dice : Let's gamble";
                  cursor(HAND);
                }
     
    }
     

}

//Controls the textfeed from the mid mouse wheel
void mouseWheel(int delta) {
  println("txNr: " + textfeedNr);
  if(delta>0 && textfeedNr <= textfeed.size()){
    textfeedNr++;
  }else if(delta<0 && textfeedNr > 0){
    textfeedNr--;
    } else {
      
    }
    
}






  

void mouseReleased() {
  if(dialMode){
  // loop through all the button objects and run release functions.
  for(int i=1; i<buttonsArray.length; i++){
    buttonsArray[i].release();
  }
  }
}
  
  

/*
 XML event class
*/
 void xmlEvent(proxml.XMLElement element){
 xml_areas = element;
}
 



















/* The class Area is each square, it knows it initial position, and have methods to report if anything happens (collition), should also know which Actors currently (and historically) located within */

class Area {
  int xpos;
  int ypos;
  String name;
  boolean mic;
  boolean cam;
  boolean heard;
  boolean seen;
  String[] playerMem;
  ArrayList al;
  int imagepos;
  
  
  //Constructor: Informs the square about its position
 Area(int x, int y, String name){
  this.xpos = x;
  this.ypos = y;
  this.name = name;
  mic = false;
  cam = false;
  al = new ArrayList();
  heard = false;
  seen = false;
  playerMem = new String[memorynum];

 }
 
 //Returns true if something happens during the turn //now just reporting false due to lacking logic implemented
 boolean somethingHappened(){
   if(al.size() >= 2){
     return true;
  } else{
    return false;
  }
 }

 void signIn(Actor at){
   al.add(at);
   if(mic){
     textfeed.add(c.getShortTime(0)+": The police heard someone passing in "+ name+" ("+xpos+"."+ ypos+")");
    //sc.playWalk();  
   } else if(cam){
     at.known = true;
     textfeed.add(c.getShortTime(0)+": Your informant saw "+at.name +" passing in "+ name+" ("+xpos+"."+ ypos+")");
   }
 }
 
 void signOut(Actor at){
   al.remove(at);
 }
 
 
 void writeMemory(int turn, boolean status){
   if(!status){
     this.heard = true;
   }
   if(status){
    this.seen = true; 
   }     
} 


}






//Superclass actor. Know direction and objective where it is going. 
class Actor { 
    int actNr;
    Control c;
    int xpos;
    int ypos;
    public String name;
    boolean dirlead; // Indicates which direction which is being followed: true = x, false = y
  boolean dirx; // Indicates the way the x-axis is moving; true = increasing, false = decreasing
  boolean diry; // Indicates the way the y-axis is moving; true = increasing, false = decreasing
  boolean known; 
 
  int changer; //A number between 0 and 5 which describes how many interferences Actor will accept before changing dirlead
  int changer_status; //The current number. 
  Area[] memory; //makes up the memory of the Actor
  
  //Constructor: Informs on initial possition within the grid
  
 Actor(int x, int y, Control c, int actNr, String name){
  this.xpos = x;
  this.ypos = y;
  this.c = c;
  this.known = false;
  this.actNr = actNr;
  this.name = name;
  this.memory = new Area[rHN];
  
  
    
    
      // place initial directions for movement
    if(int(random(2)) == 1){
      dirlead = false;
    } else {
      dirlead = true;
    }
  
    if(int(random(2)) == 1){
      dirx = false;
    } else {
       dirx = true;      
    }
    
    if(int(random(2)) == 1){
      diry = false;
    } else {
      diry = true;
    }
    
    changer = int(random(5));
    changer_status = 0;
    
    areas[xpos][ypos].signIn(this); //Signing object into place in Matrix
    memory[turncounter] = areas[xpos][ypos];
    
    
    
 } // end of constructor 
  

  //returns X position
  int whereAreYouX(){
     return this.xpos;
  }
  
  // returns Y position
   int whereAreYouY(){
     return this.ypos;
  }
  
  
  //Move the Actor one step in direction, checks for borders before moving
   void move(){
     checkDirection();
 //   println(actNr+" moved from square"+xpos+","+ypos);
     areas[xpos][ypos].signOut(this);
     
     
     if(dirlead == true){
         checkBordersX();
         if(dirx == true){
          this.xpos++; 
         } else {
           this.xpos--;
         }   
     } else if(dirlead == false){
         checkBordersY();
         if(diry == true){
          this.ypos++; 
         } else {
           this.ypos--;
         }
         
     }
   //  println(actNr+" moved to square"+xpos+","+ypos);
     areas[xpos][ypos].signIn(this);
     memory[turncounter] = areas[xpos][ypos];
  
  } //EndOf move()
  
  void moveTo(Area a){
    this.xpos = a.xpos;
    this.ypos = a.ypos;
    
  }
  

//Check for X borders, changes variable direction if border is next step
void checkBordersX(){
   if(this.xpos >= gsx-1 || this.xpos == 0){
    // println("xpos something");
     if(this.xpos == gsx-1){
       this.dirx = false; 
       changer_status++;
      // println("xpos false something");
     } else if(this.xpos == 0){
       this.dirx = true;
       changer_status++;
      // println("xpos true something");
     } else {
      println("SystemERROR");
      }
   }
  } //endOf checkBordersX
  
//Check for Y borders, changes variable direction if border is next step  
  void checkBordersY(){
   if(this.ypos >= gsy-1 || this.ypos == 0){
       if(this.ypos == gsy-1){
           this.diry = false;
           changer_status++;
     } else if(this.ypos == 0){
          this.diry = true;
          changer_status++;
     } else {
      println("SystemERROR");
      }
    } 
  
  }//EndOf checkBordersY
  
  void checkDirection(){
    if(changer == changer_status){
      if(dirlead == true){
        dirlead = false; 
      } else if(dirlead == false){
       dirlead = true ;
      }
      changer_status = 0;
    }
  
  }
  
  
  void updatePosition(){
    areas[this.xpos][this.ypos].signOut(this);
    this.xpos = memory[turncounter].xpos;
    this.ypos = memory[turncounter].ypos;
    areas[this.xpos][this.ypos].signIn(this);
    
    
  }

}//EndOf class Actor







//Subclass Suspect. Sends variables to superclass, but helps identifying role, and can be implemented with role specific variables and methods
class Suspect extends Actor{
  Suspect(int x,int y, Control c, int actNr, String name){
    super(x,y,c,actNr, name);  
  }
  
  
  
  
  
} //EndOf class Suspect



//Subclass Victim. Sends variables to superclass, but helps identifying role, and can be implemented with role specific variables and methods
class Victim extends Actor{
  Victim(int x, int y, Control c, int actNr, String name){
    super(x,y,c, actNr, name);  
  }//EndOf Constructor Victim
  
  
  
  
  
} // EndOf class Victim




/* Control class, object is created in setup. Creates the objects, makes the world go round, and is very important for the whole execution. */

class Control{
//Creates the Areas in the grid
   void createAreas(){
      areas = new Area[gsx][gsy];
      proxml.XMLElement tempobj = null;
      println("We get inside the control, and start to create areas");
      for(int i=0; i < gsx;i++){
        for(int j=0; j <gsy; j++){
          
          if(i == 0 && j == 0){
           tempobj = xml_areas.firstChild(); 
          } else {
           tempobj = tempobj.nextSibling();
          } 
          
          String name = tempobj.getAttribute("name");
          areas[i][j] = new Area(i,j,name);
        }          
    }  
  }
  
  //Creates the Actors, and places them at random location in the grid
  void createActors(){
    actors = new Actor[numSusp+numVict];
     for(int i = 0; i < numSusp; i++){
       actors[i] = new Suspect(int(random(gsx)),int(random(gsy)),this,i,suspNames[i]); 
     }
     for(int j =0+numSusp; j < numSusp+numVict; j++){
       actors[j] = new Victim(int(random(gsx)),int(random(gsy)),this,j,victNames[j-numSusp]); 
     } 
     print("Created actors");
  }



//iterates through the objects of Actors and calls the make turn object.
//More logic to be placed here for each iteration, can be divided into more methods. 

void makeTurn(){

    //Asks the actors to move
    if(simulationMode){
   for(int i=0; i<numSusp+numVict; i++){
    actors[i].move();
   } 
    }
   //Check in anthing has happened in the model
   for(int i=0; i < gsx;i++){
        for(int j=0; j <gsy; j++){
          if(areas[i][j].somethingHappened() == true){
            findCollision(areas[i][j]);
          }
          
           if(!areas[i][j].heard && areas[i][j].cam){
             areas[i][j].writeMemory(turncounter, false); 
           }
           if(!areas[i][j].seen && areas[i][j].cam){
             areas[i][j].writeMemory(turncounter, true); 
           }
          
        }
   }
   
   //registers another turn
   if(simulationMode){
   turncounter++;
   }

  } //EndOf makeTurn()
  
  
  
 //Should find collusion, does this by checing if objects of both 
  // subclasses is within the area a. Not generic enough. Runs only during 
  //simulation and does not spot interchanging between spaces. 
  //THIS METHOD HAS TO BE CHANGED TO A BETTER ONE
  void findCollision(Area a){
   int vict = 0;
   int susp = 0;
   //Iterates through visitor database, and updates what class is within the Area
    for(int i = 0; i< a.al.size(); i++){
       if(a.al.get(i) instanceof Victim){ //Checks if class ID and updates counter
         vict++; //Updates the number of victims within field
       }else if(a.al.get(i) instanceof Suspect){
           susp++; //Updates the number of suspect within field
       } else {
        print("we should not get this message here"); //This should never happen
       }
     }
     //If more than one victim AND more than one suspect means kill
     //if in siulation mode, start the game. If not play murder sound. 
     if(susp >= 1 && vict >= 1){
        if(turncounter>memorynum){
          if(simulationMode){
         // println("Startgame");
          murderArea = a;
          for(int i = 0; i< a.al.size(); i++){
            if(a.al.get(i) instanceof Suspect){
            murderer = (Actor) a.al.get(i);
            }
          }
           
           startgame();
          } else {
             if(a.mic && a == murderArea){
           textfeed.add(c.getShortTime(0)+"The police heard a murder in "+ a.name+" ("+a.xpos+"."+ a.ypos+")"); 
             oscS.sendMessage("playDeath/heard");
       } else if(a.cam && a == murderArea){
          textfeed.add("OMG A kille"+ a.name+" ("+a.xpos+"."+ a.ypos+ ") at"+c.getShortTime(0)); 
            oscS.sendMessage("playDeath/seen");
            println("THIS SHOULD LEAVE US TO ENDSCREEN");
            resultText = "Your informant saw the murder happen. "+murderer.name+" killed an innocent human being";
            endScreen = true;
             for(int i = 0; i< a.al.size(); i++){
             //  if(a.al.get(i) instanceof Suspect){ String tempSusp = a.al.get(i).name; }
             }
   
       }  
       }
      
    } 
      //check if more than one suspect is in the area
     } else if(susp >= 2){
          if(a.mic){
        textfeed.add(c.getShortTime(0)+" You heard two Suspects meet in in"+ a.name+" ("+a.xpos+"."+ a.ypos+ ")"); 
          oscS.sendMessage("playSuspectMeet/heard");
       } else if(a.cam){
         textfeed.add(c.getShortTime(0)+" You saw two Suspects meet in"+ a.name+" ("+a.xpos+"."+ a.ypos+ ")");
          oscS.sendMessage("playSuspectMeet/seen");
       }
       //check if more than one victim is in the area
     } else if (vict >= 2){
       if(a.mic){
        textfeed.add(c.getShortTime(0)+" You heard two Victim meet in in"+ a.name+" ("+a.xpos+" . "+ a.ypos+ ")");
        oscS.sendMessage("playVictimMeet/heard"); 
       } else if(a.cam){
         textfeed.add(c.getShortTime(0)+" You saw two Victim meet in"+ a.name+" ("+a.xpos+" . "+ a.ypos+ ")");
         oscS.sendMessage("playVictimMeet/seen"); 
       }
     } else {
       println("System ERROR"); // Should never logically occur
     }

  }//EndOf function findCollition
    
    
    //Takes control and creates turns until murder which turns of simulationMode
   void runsimulation(){
     while(simulationMode){
     c.makeTurn();
     }
     videoMode = true; // Sets videoMode to true to start opening sequence 
   }
   
   //Method restarts the game, by rerunning the simulation
   void restart(){
      murdernum = 0;
      turncounter = 0; //Reset the turn counter
      simulationMode = true;  //Starts in simulation mode
      createAreas();
      createActors();
      runsimulation();
      
     
   }//End of method restart()
  
  
    //Start game turns of simulation mode, and enters draw loop
    void startgame(){
     simulationMode = false;
     murdernum = turncounter; //Stores the turn when the murder found place
      
    }//End of method StartGame
    
    
    //Return a String with time since beginning of simulation - Subtracts the number from num
    String gettime(int num){
     String time;
     int days = 0 ;
     int hours = 0; 
     int calctime = (turncounter -num);
     
     //Runs through calc time and divides into days first, then hours
     while(calctime > 0){
       if(calctime >= 24){
         days++;
         calctime = calctime - 24;
       }else if(calctime < 24){
        hours = calctime; 
        calctime = 0;
       } 
     }     
     //Concatinate String consisting of timestamp, and returns this.
     time = "Days:"+String.valueOf(days)+" Time:"+String.valueOf(hours);
     return time;
    } //End of Method gettime
    
    int getHour(int num){
      
     int days = 0 ;
     int hours = 0; 
     int calctime = (turncounter -num);
     
     //Runs through calc time and divides into days first, then hours
     while(calctime > 0){
       if(calctime >= 24){
         days++;
         calctime = calctime - 24;
       }else if(calctime < 24){
        hours = calctime; 
        calctime = 0;
       } 
     }  
    
     return hours;
    }
    
    String getShortTime(int num){
      String time;
     int days = 0 ;
     int hours = 0; 
     int calctime = (turncounter -num);
     
     //Runs through calc time and divides into days first, then hours
     while(calctime > 0){
       if(calctime >= 24){
         days++;
         calctime = calctime - 24;
       }else if(calctime < 24){
        hours = calctime; 
        calctime = 0;
       } 
     }     
     //Concatinate String consisting of timestamp, and returns this.
     time = "D:"+String.valueOf(days)+" T:"+String.valueOf(hours);
     return time;
    } //End of Method gettime
      
      
      
      
    
    
    
    
    
    //Changes the turn one backward, unless at end of memory
    boolean rewindTurn(){
      //println("Should rewind");
      //Changes the turn one backward, unless at end of memory
      if(turncounter>murdernum-memorynum){
      turncounter --;
         //Tells actors to update possition
       for(int i=0; i<numSusp+numVict; i++){
          actors[i].updatePosition();
       } return true;
      } else {
         return false;
      }      
    }//end of method rewindTurn()
    
 
    //Moves the state one turn forward unless at murder
    boolean forwardTurn(){
      //Changes turn one forward if we are in the past
      if(turncounter<murdernum){
        turncounter ++;
         // asks the actors to do their turns
       for(int i=0; i<numSusp+numVict; i++){
          actors[i].updatePosition();
          c.makeTurn();
       } return true;
      } else {
       return false;
       }
    }//end of method forwardTurn()
    
    
      //Method backToReRun sets the state of the game to number of turns minus memory
       void backToReRun(){
      turncounter = murdernum - memorynum;
      
    }//End of method backToReRun
    
    
    //Method reRunSimulation() runs through the events leading up to the murder
    void reRunSimulation(){
      backToReRun();
      while(forwardTurn()){
      };
      
    } //End of method reRunSimulation
    
    
    //Switches the Cameras and the Microphones to false
    void clearTools(){
      
      for(int i=0;i<gsx;i++){
        for(int j=0;j<gsy;j++){
          areas[i][j].cam = false;
          areas[i][j].mic = false;
        }
      }

    }
    
    //Receives a textstring from phone, compares and delegates.
    void processNumber(String s){
      println("The process number thing was called");
      String pizza = "9136";
      String informant = "7824";
      dialMode = false;

      if(s.equals(pizza)){
        println("The number Pizza has been chosen");
        phoneMode = false;
        oscS.sendMessage("phone/pizza");
        main_filter = false;
        click_filter = false;
        
      } else if(s.equals(informant)){
        println("The number Informant has been chosen");
        oscS.sendMessage("phone/informant");
        
      } else{
        println("Not a valid number");
        phoneMode = false;
        main_filter = false;
        click_filter = false;
        oscS.sendMessage("phone/dead");
        
      }
      
      
      
    }
   
     
}//End of class Control


/*
OSCSender handles messages sent from the program and forwards them to the 
Max Runtime patch using Open Sound Control
*/
 
 class OSCSender {
  
  OSCSender(PApplet pap) {
      oscP5 = new OscP5(pap,7400);
      myRemoteLocation = new NetAddress(nettAddr,7400);
  }
 
   //Method takes a message adds prefix and ship it away
  void sendMessage(String message){
    OscMessage myMessage = new OscMessage("nln/message/"+message);
  oscP5.send(myMessage, myRemoteLocation); // send the message
  } 
 }
 


 /*
 This class handles analytics throughout the game
   We surveillance several thresholds, and clicks,
   also whether a user completes the game 
   Using the HTTP protocol, and several differents script on server
   */
   
 class Analytics {
   URLConnection conn;
   
   
   Analytics(){
     try{
       URL startUrl = new URL("http://nonlinearnarrative.org/analytics/start.php?gameID="+uniqueID);
        conn = startUrl.openConnection();
        conn.connect();
        HttpURLConnection http = (HttpURLConnection) conn; 
        http.getResponseCode();
  
     } catch(Exception e){
      println("Could not create URL's and send start signal"); 
     }
     
   }
   
   //Registers endagame
   void registerEndGame() {
     try{
       URL completeUrl = new URL("http://nonlinearnarrative.org/analytics/complete.php?gameID="+uniqueID+"&turns="+gameCount); 
        conn = completeUrl.openConnection();
        conn.connect();
        HttpURLConnection http = (HttpURLConnection) conn; 
        http.getResponseCode();
        http.disconnect();
        println("register endgame");
      } catch(Exception e){
      println("Could not create URL's and send start signal"); 
     }
     
   }
   
   //Registers threshold on Whisky
   void registerGotDrunk() {
     try{
    URL actionUrl = new URL("http://nonlinearnarrative.org/analytics/gotDrunk.php?gameID="+uniqueID);
    conn = actionUrl.openConnection();
        conn.connect();
        HttpURLConnection http = (HttpURLConnection) conn; 
        http.getResponseCode();
        http.disconnect();
        println("register got drunk");


       } catch(Exception e){
          println("Could not create URL's and send start signal"); 
       }    
     
   }
   
   //Registers threshold on Gun
   void registerScaredNeighbour(){
     try{
    URL actionUrl = new URL("http://nonlinearnarrative.org/analytics/scaredNeighbour.php?gameID="+uniqueID);
        conn = actionUrl.openConnection();
        conn.connect();
        HttpURLConnection http = (HttpURLConnection) conn; 
        http.getResponseCode();
        http.disconnect();
        
        println("register scared neighbour");
     
       } catch(Exception e){
          println("Could not create URL's and send start signal"); 
       }        
   }
   
   //Registers threshold on subjects
   void registerFoundSuspects(){
     try{
    URL actionUrl = new URL("http://nonlinearnarrative.org/analytics/foundSuspects.php?gameID="+uniqueID);
        conn = actionUrl.openConnection();
        conn.connect();
        HttpURLConnection http = (HttpURLConnection) conn; 
        http.getResponseCode();
        http.disconnect();
        
        println("register found suspects");
     
       } catch(Exception e){
          println("Could not create URL's and send start signal"); 
       }        
   }

   
 }
 



