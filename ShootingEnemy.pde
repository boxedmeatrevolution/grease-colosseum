// An enemy that shoots at you!
class ShootingEnemy extends EnemyEntity {
  
  // Constants
  final float _MASS = 1;
  final float _RADIUS = 16;
  final int _VALUE = 5;
  final float _HP = 1;
  final float _ACCELERATION = 1200;
  final float _GREASE_ACCELERATION = 200;
  final float _FRICTION = 600;
  final float _MAXVELOCITY = 50;
  final float _TURN_SPEED = 1;
  
  ShootingEnemy(float x_, float y_, float facingDirection_) {
    super(x_, y_, _MASS, _RADIUS, _FRICTION, _VALUE, _HP, facingDirection_, _ACCELERATION, _MAXVELOCITY, _GREASE_ACCELERATION, _TURN_SPEED);
    timeUntilNextFire = random(50, 100);
  }
  
  void onCollision (Collider cOther, boolean wasHandled) {
    super.onCollision(cOther, wasHandled);
  }
  
  void create () {
    super.create();
  }
  
  void destroy () {
    super.destroy();
  }
  
  void render () {
    super.render();
    fill(color(0, 255, 0));
    ellipse(x, y, 2 * radius, 2 * radius);
    line(x, y, x + radius * cos(facingDirection), y - radius * sin(facingDirection));
    fill(255);
  }
  
  void hitEdge () {
    super.hitEdge();
  }
  
  void turnTowardsPlayer (float delta) {
    super.turnTowardsPlayer(delta);
  }
  
  void walkTowardsPlayer (float delta) {
    super.walkTowardsPlayer(delta);
  }
  
  int timeUntilNextFire;
  
  void update (int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      walkTowardsPlayer(delta);
      turnTowardsPlayer(delta);
      if (timeUntilNextFire <= 0) {
        timeUntilNextFire = random(50, 100);
        
        if (player != null){
          addEntity(makeBullet());
        }
      } else {
        timeUntilNextFire--;
      }
    }
  }
  
  Bullet makeBullet () {
    float dx = player.x - x;
    float dy = player.y - y;
    float len = iDist(0,0, dx,dy);
    
    dx *= 15f/len;
    dy *= 15f/len;
    
    return new Bullet(x,y, dx,dy, player);
  }
  
}





