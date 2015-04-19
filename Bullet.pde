// A class for the bullets Shooting Enemies Shoot. 
class Bullet extends Entity {
  
  Player player;
  
  float x, y;
  float dx, dy;
  
  Bullet (float _x, float _y, float _dx, float _dy, Player _player) {
    x = _x;
    y = _y;
    dx = _dx;
    dy = _dy;
    player = _player;
  }
  
  void create () {}
  
  void destroy () {}
  
  void update (int phase, float delta) {
    if (phase == 0) {
      x += dx;
      y += dy;
      
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
    float px = cl.x;
    float py = cl.y;
    float pr = cl.radius;
    
    float vx = px - x;
    float vy = py - y;
    
    vx -= dx*((dx*vx + dy*vy) / (sq(dx) + sq(dy)));
    vy -= dy*((dx*vx + dy*vy) / (sq(dx) + sq(dy)));
    
    return iDist(0,0, vx, vy) <= pr && iDist(x,y, px - vx, py - vx) <= iDist(0,0, dx, dy);
  }
  
  //Is run when cl is hit by the bullet!!
  void collided (Collider cl) {
    //if (cl instanceof Player) ((Player) cl).kill();
    if (cl instanceof Barrel) ((Barrel) cl).explode();
    //removeEntity(this);
  }
  
  void render () {
    float nx = x + dx;
    float ny = y + dy;
    strokeWeight(3);
    stroke(color(255,255,255));
    line(x,y,nx,ny);
    strokeWeight(1);
  }
  
}

float iDist (float x, float y, float a, float b) {
  return sqrt(sq(x-a) + sq(y - b));
}
