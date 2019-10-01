import ddf.minim.*;                          //todo :names for score bord
Minim minim;
AudioPlayer laserPlayer; 
AudioPlayer jessieScream[];
AudioPlayer exp;
Spider spider[];
Explosion explosion[];
PImage jessieImg;
PImage bayMaxImg;
PImage spiderImg;
PImage explosionImg;
float jessieAngle=3*PI/2;
float jessieAngleDelta=0.0;
float bayMaxAngle=3*PI/2;
float bayMaxAngleDelta=0.0;
boolean pew=false;
boolean bad=false;
long lastPewMillis=0;
boolean canPew=false;
boolean pop=false;
boolean good=false;
long lastpopMillis=0;
long lastPopMillis=0;
boolean canPop=false;
int screamType=0;
float jessieX=400;
float jessieY=500;
float jessieSpeed=0;
float bayMaxX=400;
float bayMaxY=500;
float bayMaxSpeed=0;
int jessieScore=0;
int bayMaxScore=0;
int spiderScore=0;
void setup() {
  minim=new Minim(this);
  fullScreen();    
  imageMode(CENTER);
  background(#4A006A);
  jessieImg=loadImage("data/jessie.png");
  bayMaxImg=loadImage("data/bayMax.png");
  spiderImg=loadImage("data/spider.png");
  explosionImg=loadImage("data/explosion.png");
  spider=new Spider[100];
  explosion=new Explosion[100];
  frameRate(60);
  strokeWeight(6);
  stroke(255, 0, 0);
  laserPlayer = minim.loadFile("data/laser.wav");  
  exp = minim.loadFile("data/exp.wav");
  jessieScream=new AudioPlayer[5];
  for (int i=0; i<jessieScream.length; i++) {
    jessieScream[i] = minim.loadFile("data/scream"+i+".wav");
  }
  for (int i=0; i<spider.length; i++) {
    spider[i]=new Spider();
  }
  for (int i=0; i<explosion.length; i++) {
    explosion[i]=new Explosion();
  }
}
void draw() {
  jessieAngleDelta=constrain(jessieAngleDelta, -.2, .2);
  jessieAngle+=jessieAngleDelta;
  jessieX+=jessieSpeed*cos(jessieAngle);
  jessieY+=jessieSpeed*sin(jessieAngle);
  if (jessieX<0) {
    jessieX+=width;
  }
  if (jessieX>width) {
    jessieX-=width;
  }
  if (jessieY<0) {
    jessieY+=height;
  }
  if (jessieY>height) {
    jessieY-=height;
  }
  bayMaxAngleDelta=constrain(bayMaxAngleDelta, -.2, .2);
  bayMaxAngle+=bayMaxAngleDelta;
  bayMaxX+=bayMaxSpeed*cos(bayMaxAngle);
  bayMaxY+=bayMaxSpeed*sin(bayMaxAngle);
  if (bayMaxX<0) {
    bayMaxX+=width;
  }
  if (bayMaxX>width) {
    bayMaxX-=width;
  }
  if (bayMaxY<0) {
    bayMaxY+=height;
  }
  if (bayMaxY>height) {
    bayMaxY-=height;
  }
  if (!bad) {
    background(#4A006A);
  } else {
    background(155, 0, 20);
    spiderScore++;
    jessieScream[screamType].rewind();
    jessieScream[screamType].play();
    screamType++;
    if (screamType>jessieScream.length-2) {
      screamType=0;
    }
  }
  textSize(width/50);
  fill(255);
  text(spiderScore, width/4, height*.1);
  text(jessieScore, width*3/4, height*.1);
  if (frameCount%(constrain(100-frameCount*100/4000, 2, 100))==0) {
    for (int i=0; i<spider.length; i++) {
      if (spider[i].alive==false) {
        spider[i].start(random(0, TWO_PI), random(width*.05, width*.1), random(height/constrain(map(frameCount, 0, 4000, 500, 100), 100, 500), random(height/constrain(map(frameCount, 0, 4000, 300, 40), 40, 300))));
        i=spider.length;
      }
    }
  }
  text("spiders Eating Jessie", width/6, height*.07); 
  text("Pew Pew Points", width*.69, height*.07); 
  if (canPew) {
    if (millis()-lastPewMillis>500) {
      lastPewMillis=millis();
      laserPlayer.rewind();
      laserPlayer.play();
      pew=true;
    } else {
      pew=false;
    }
  } else {
    pew=false;
  }
  if (canPop) {
    if (millis()-lastPopMillis>500) {
      lastPopMillis=millis();
      laserPlayer.rewind();
      laserPlayer.play();
      pop=true;
    } else {
      pop=false;
    }
  } else {
    pop=false;
  }
  bad=false;
  for (int i=0; i<spider.length; i++) {
    spider[i].run();
    if (pew==true&&spider[i].alive==true&&abs(((TWO_PI+atan2(+spider[i].y-jessieY, spider[i].x-jessieX))%TWO_PI)-jessieAngle)<abs(atan(spider[i].size/2/sqrt(sq(spider[i].y-jessieY)+sq(spider[i].x-jessieX))))) {      
      spider[i].alive=false;
      jessieScore++;
      explosion[i].boom(spider[i].x, spider[i].y);
      exp.rewind();
      exp.play();
    }
  }
  good=false;
  for (int i=0; i<spider.length; i++) {
    spider[i].run();
    if (pop==true&&spider[i].alive==true&&abs(((TWO_PI+atan2(+spider[i].y-bayMaxY, spider[i].x-bayMaxX))%TWO_PI)-bayMaxAngle)<abs(atan(spider[i].size/2/sqrt(sq(spider[i].y-bayMaxY)+sq(spider[i].x-bayMaxX))))) {      
      spider[i].alive=false;
      bayMaxScore++;
      explosion[i].boom(spider[i].x, spider[i].y);
      exp.rewind();
      exp.play();
    }
  }

  for (int i=0; i<explosion.length; i++) {
    explosion[i].run();
  }
  pushMatrix();
  translate(jessieX, jessieY);
  rotate(jessieAngle+1.08*PI/2);
  image(jessieImg, 0, 0, height*.1, height*.1);
  popMatrix();
  if (millis()-lastPewMillis<500) {
    stroke(255, 0, 0, map(millis()-lastPewMillis, 0, 100, 255, 0));
    line(jessieX, jessieY, cos(jessieAngle)*(width+height)+jessieX, sin(jessieAngle)*(width+height)+jessieY);
  }
  pushMatrix();
  translate(bayMaxX, bayMaxY);
  rotate(bayMaxAngle+1.08*PI/2);
  image(bayMaxImg, 0, 0, height*.1, height*.1);
  popMatrix();
  if (millis()-lastPopMillis<500) {
    stroke(255, 0, 0, map(millis()-lastPopMillis, 0, 100, 255, 0));
    line(bayMaxX, bayMaxY, cos(bayMaxAngle)*(width+height)+bayMaxX, sin(bayMaxAngle)*(width+height)+bayMaxY);
  }
}
void keyPressed() {
  if (key==CODED&&keyCode==DOWN) {
    jessieSpeed-=2;
  }
  if (key==CODED&&keyCode==UP) {
    jessieSpeed+=2;
  }
  if (key==CODED&&keyCode==LEFT) {
    jessieAngleDelta-=.15;
  }
  if (key==CODED&&keyCode==RIGHT) {
    jessieAngleDelta+=.15;
  }
  if (jessieAngle>TWO_PI) {
    jessieAngle-=TWO_PI;
  }
  if (jessieAngle<0) {
    jessieAngle+=TWO_PI;
  }
  if (key==' ') {
    canPew=true;
  }
  if (key=='s') {
    bayMaxSpeed-=2;
  }
  if (key=='w') {
    bayMaxSpeed+=2;
  }
  if (key=='a') {
    bayMaxAngleDelta-=0.15;
  }
   if (key=='d') {
    bayMaxAngleDelta+=0.15;
   }
  if (key=='s') {
    bayMaxSpeed-=2;
  }
if (bayMaxAngle>TWO_PI) {
  bayMaxAngle-=TWO_PI;
}
if (bayMaxAngle<0) {
  bayMaxAngle+=TWO_PI;
}
if (key=='1') {
  canPop=true;
}
}
void keyReleased() {
  if (key==' ') {
    canPew=false;
  }
  if (key==CODED&&(keyCode==UP||keyCode==DOWN)) {
    jessieSpeed=0;
  }
  if (key==CODED&&(keyCode==LEFT||keyCode==RIGHT)) {
    jessieAngleDelta=0;
  }
  if (key=='1') {
    canPop=false;
  }
   if (key=='w' || key=='s') {
    bayMaxSpeed=0;
  }
  if (key=='a' || key=='d') {
    bayMaxAngleDelta=0;
  }
}
class Explosion {
  float x, y;
  int time;
  Explosion() {
    time=10000000;
  }
  void boom(float X, float Y) {
    time=0;
    x=X;
    y=Y;
  }
  void run() {
    if (time<60) {
      tint(255, map(time, 0, 60, 255, 0));
      image(explosionImg, x, y, width*.1, width*.1);
      noTint();
      time++;
    }
  }
}
class Spider {
  float angle, x, size, speed, y;
  boolean alive;
  Spider() {
  }
  void start(float positionAngle, float _size, float _speed) {
    y=height/2+sin(positionAngle)*height;
    x=width/2+cos(positionAngle)*width;
    angle= atan2(jessieY-y, jessieX-x);
    size=_size;
    speed=_speed;
    alive=true;
  }
  void fire(float positionAngle, float _size, float _speed) {
    y=height/2+sin(positionAngle)*height;
    x=width/2+cos(positionAngle)*width;
    angle= atan2(bayMaxY-y, bayMaxX-x);
    size=_size;
    speed=_speed;
    alive=true;
  }
  void ran() {
    if (alive) {
      y+=speed*sin(angle);
      x+=speed*cos(angle);
      if (dist(x, y, width/2, height/2)>max(height, width)*1.1) {
        alive=false;
      };
      pushMatrix();
      translate(x, y);
      rotate(angle-HALF_PI);
      image(spiderImg, 0, 0, size, size);
      popMatrix();
      if (abs(x-jessieX)<(size/2)&&abs(y-jessieY)<(size/2)) {
        bad=true;
        alive=false;
      }
    }
  }
  void run() {
    if (alive) {
      y+=speed*sin(angle);
      x+=speed*cos(angle);
      if (dist(x, y, width/2, height/2)>max(height, width)*1.1) {
        alive=false;
      };
      pushMatrix();
      translate(x, y);
      rotate(angle-HALF_PI);
      image(spiderImg, 0, 0, size, size);
      popMatrix();
      if (abs(x-jessieX)<(size/2)&&abs(y-jessieY)<(size/2)) {
        bad=true;
        alive=false;
      }
    }
  }
}
