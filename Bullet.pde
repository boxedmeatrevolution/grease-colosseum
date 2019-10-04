// A class for the bullets Shooting Enemies Shoot. 
class Bullet extends Entity {
  float x, y;
  float dx, dy;
  
  Bullet (float _x, float _y, float _dx, float _dy) {
    x = _x;
    y = _y;
    dx = _dx;
    dy = _dy;
    
  }
  
  void create () {
    super.create();
    if (ninjaStarSheet == null) {
      ninjaStarSheet = loadSpriteSheet("./assets/ninja_star.png", 4, 1, 24, 24);
    }
    ninjaStarAnimation = new Animation(ninjaStarSheet, 0.2, 0, 1, 2, 3);
  }
  
  void destroy () {
    super.destroy();
  }
  
  void update (int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      ninjaStarAnimation.update(delta);
      x += dx * delta;
      y += dy * delta;
      
      //If bullet has left the screen
      if (x < 0 || y < 0 || x > width || y > height) {
        removeEntity(this);
      } else {
        for (Collider cl : colliders) {
          if (cl != null && colliding(cl)) collided(cl);
        }
      }
    }
  }
  
  //Test if cl is hit by bullet
  boolean colliding (Collider cl) {
    /*float px = cl.x;
    float py = cl.y;
    float pr = cl.radius;
    
    float vx = px - x;
    float vy = py - y;
    
    vx -= dx*((dx*vx + dy*vy) / (sq(dx) + sq(dy)));
    vy -= dy*((dx*vx + dy*vy) / (sq(dx) + sq(dy)));
    
    return iDist(0,0, vx, vy) <= pr && iDist(x,y, px - vx, py - vx) <= iDist(0,0, dx, dy);*/
    return iDist(x, y, cl.x, cl.y) <= cl.radius + 8;
  }
  
  //Is run when cl is hit by the bullet!!
  void collided (Collider cl) {
    if (cl instanceof Player) ((Player) cl).hurt();
    if (cl instanceof Barrel) ((Barrel) cl).explode();
    //removeEntity(this);
  }
  
  void render () {
    super.render();
    ninjaStarAnimation.drawAnimation(x - 12, y - 12, 24, 24);
  }
  
  int depth() {
    return -80;
  }
  
  Animation ninjaStarAnimation;
  
}

float iDist (float x, float y, float a, float b) {
  return sqrt(sq(x-a) + sq(y - b));
}

SpriteSheet ninjaStarSheet;
