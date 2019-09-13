final float fieldWidth = 1000;
final float fieldHeight = 1000;
final float defaultLifeSize = 10;
final float defaultRegionSize = 80;
final float initialPopulationSize = 100;




bool isMouseClicked=false;
void mousePressed(){
  isMouseClicked=!isMouseClicked;
  }
void drawTriangle(int x, int y, int r, float rot) {
  pushMatrix();
  translate(x, y);  // 中心となる座標
  console.log(degrees(rot));
  rotate(rot - PI/2);

  // 円を均等に3分割する点を結び、三角形をつくる
  beginShape();
    vertex(r*cos(PI/2), r*sin(PI/2));
    vertex(r*cos(0)/2, rot/4);
    vertex(r*cos(PI)/2, rot/4);
  endShape(CLOSE);
  beginShape();
    vertex(0, 0);
    vertex(r*cos(3*PI/2), r*sin(3*PI/2));
  endShape(CLOSE);


  popMatrix();
}

class Life {
  PVector position;
  PVector velocity;
  float size;
  float regionSize;
  PVector totalVelocity;
  PVector totalPosition;
  PVector distanceShouldMade;
  int howMuchInRegion;
  float coeff_vel;
  float coeff_pos;
  float coeff_dis;
  float coeff_self;

  void initialize(PVector _position, float _coeff_vel,float _coeff_pos, float _coeff_dis, float _coeff_self){
    coeff_vel=  _coeff_vel;
    coeff_pos=  _coeff_pos;
    coeff_dis=  _coeff_dis;
    coeff_self= _coeff_self;
    position = _position;
    size = defaultLifeSize;
    regionSize = defaultRegionSize;
    velocity = new PVector(random(-1, 1), random(-1,1));
    totalVelocity = new PVector(0, 0);
    totalPosition = new PVector(0, 0);
    howMuchInRegion = 0
    distanceShouldMade = new PVector(0, 0);
  }

  Life(PVector _position, float _coeff_vel, float _coeff_pos, float _coeff_dis, float _coeff_self){
    initialize(_position,  _coeff_vel, _coeff_pos,  _coeff_dis,  _coeff_self);
  }
  Life(float x, float y, float _coeff_vel, float _coeff_pos, float _coeff_dis, float _coeff_self){
    position = new PVector(x,y);
    initialize(position,   _coeff_vel, _coeff_pos,  _coeff_dis,  _coeff_self);
  }
  void onCollisionStay(Life other){
    distanceShouldMade.add(PVector.sub(position, other.position));
  }
  void onRegionStay(Life other){
    totalVelocity.add(other.velocity);
    totalPosition.add(other.position);
    PVector diff = PVector.sub(position,other.position);
    if(this != other && diff.mag()<(regionSize+other.regionSize)/4){
      float force = 1200/(diff.mag());
      diff.normalize();
      diff.mult(force);
      distanceShouldMade.add(diff);
    }
    howMuchInRegion +=1;
  }
  void draw(){
    noStroke();
    fill(255, 0, 0, 2);
    ellipse(position.x, position.y, regionSize, regionSize);

    stroke(0);
    fill(256*(coeff_pos), 256*coeff_vel, 256*coeff_self);
    ellipse(position.x, position.y, size, size);

    fill(255,0,0);
    drawTriangle(position.x, position.y, size/2, velocity.heading());
  }

  void update(){
    PVector averageVelocity=new PVector(0,0);
    PVector averagePosition=new PVector(0,0);
    PVector diff=new PVector(0,0);
    PVector averageDistance=new PVector(0,0);
    PVector mousePosition = new PVector(fieldWidth/2, fieldHeight/2);
    PVector vecToMouse = PVector.sub(mousePosition, position);

    if(howMuchInRegion !=0){
      averageVelocity = PVector.div(totalVelocity, howMuchInRegion);
      averagePosition = PVector.div(totalPosition, howMuchInRegion);
      diff = PVector.sub(averagePosition, position);
      averageDistance = PVector.div(distanceShouldMade, howMuchInRegion);
      //console.log("pos"+averagePosition);
      //console.log("vel"+averageVelocity);
      //console.log("dis"+averageDistance);

      averageVelocity.normalize();
      averageVelocity.mult(coeff_vel);

      diff.normalize();
      diff.mult(coeff_pos);

      averageDistance.normalize();
      averageDistance.mult(coeff_dis);

      velocity.mult(coeff_self);

      mousePosition = new PVector(mouseX, mouseY);
      vecToMouse = PVector.sub(mousePosition, position);
      vecToMouse.normalize();
      if(isMouseClicked){
        vecToMouse.mult(-1.4);
      }
      else {
        vecToMouse.mult(0.6);
      }
    }
    //console.log(averageVelocity);
    PVector newVelocity = new PVector(0,0);
    newVelocity = PVector.add(PVector.add(PVector.add(PVector.add(velocity, diff), averageVelocity), averageDistance), vecToMouse);
    newVelocity.normalize();
    velocity = newVelocity;

    if(position.x <= size/2
    || position.y <= size/2
    || position.x >= fieldWidth-size/2
    || position.y >= fieldHeight-size/2){
      ifCollidedWithWall();
    }
    position.add(velocity);

    totalVelocity = new PVector(0, 0);
    totalPosition = new PVector(0, 0);
    distanceShouldMade =new PVector(0, 0);
    howMuchInRegion = 0;
  }
  void ifCollidedWithWall(){
    position.x = min(position.x, fieldWidth-size/2);
    position.y = min(position.y, fieldHeight-size/2);
    position.x = max(position.x, size/2);
    position.y = max(position.y, size/2);
    velocity = PVector.normalize((new PVector(random(-1, 1), random(-1,1))));
  }
}

Life[] lifes;
void setup() {
  size(fieldWidth, fieldHeight);
  background(255);
  fill(0);
  lifes = [];
  for(int i=0; i!=initialPopulationSize; i++){
    lifes[i] = new Life(random(0, fieldWidth), random(0, fieldHeight),
    2, // vel
    0.7, // pos
    0.7 + random(-0.1, 0.2), // dis
    50 // self
    );
  }
}


void drawField(){
  fill(255, 255, 255);
  rect(0, 0, fieldWidth-1, fieldHeight-1);
}

int whatTimeIsIt=0;

bool isColliding(Life l1, Life l2){
  return ((PVector.sub(l1.position, l2.position)).mag() <= (l1.size+l2.size)/2);
}
bool isInRegion(Life l1, Life l2){
  return ((PVector.sub(l1.position, l2.position)).mag() <= (l1.regionSize+l2.size)/2);
}


void draw() {
  drawField();
  whatTimeIsIt++;

  if(isMouseClicked){
    fill(255,0,0);
    ellipse(mouseX, mouseY, 5, 5);
  }else{
    fill(0,0,255);
    ellipse(mouseX, mouseY, 5, 5);
  }
  // collision
  lifes.forEach(function(Life l1){
    lifes.forEach(function(Life l2){
      if(l1 != l2 && isColliding(l1, l2)){
        l1.onCollisionStay(l2);
      }
      });
    });

  // 範囲内
  lifes.forEach(function(Life l1){
    lifes.forEach(function(Life l2){
      if(/*l1 != l2 &&*/ isInRegion(l1, l2)){
        l1.onRegionStay(l2);
      }
      });
    });

  // update
  lifes.forEach(function(Life l){
    l.update();
  });

  // draw
  lifes.forEach(function(Life l){
    l.draw();
  });
}
