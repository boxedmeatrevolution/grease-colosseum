class BigBasicEnemy extends EnemyEntity{
  BigBasicEnemy(float x_, float y_, float facingDirection_) {
    super(x_, y_, _MASS, _RADIUS, _FRICTION, _VALUE, _HP, facingDirection_, _ACCELERATION, _MAXVELOCITY, _GREASE_ACCELERATION, _TURN_SPEED);
  }
  
  void onCollision(Collider cOther, boolean wasHandled) {
    super.onCollision(cOther, wasHandled);
  }
  
  void create() {
    super.create();
  }
  
  void destroy() {
    super.destroy();
  }
  
  void render() {
    super.render();
    ellipse(x, y, 2 * radius, 2 * radius);
    line(x, y, x + radius * cos(facingDirection), y - radius * sin(facingDirection));
  }
  
  float walkTowardsPlayer(float delta) {
    return super.walkTowardsPlayer(delta);
  }
  
  float turnTowardsPlayer(float delta) {
    return super.turnTowardsPlayer(delta);
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      dist = walkTowardsPlayer(delta);
      angle = turnTowardsPlayer(delta);
      
      if (canDash) {
        if ((dist < _MAX_DIST_TO_DASH) && (angle < _MAX_ANGLE_TO_DASH)) {
          velocityX += cos(facingDirection) * _DASH_FORCE;
          velocityY -= sin(facingDirection) * _DASH_FORCE;
          canDash = false;
          dashTimer = 0;
        }
      } else {
        dashTimer += delta;
        if (dashTimer > _DASH_RELOAD) {
          canDash = true;
        }
      }
    }
  }

  //Basic Enemy properties
  float _MASS = 2;
  float _RADIUS = 32;
  int _VALUE = 20;
  float _HP = 10;
  float _ACCELERATION = 1000;
  float _GREASE_ACCELERATION = 100;
  float _FRICTION = 600;
  float _MAXVELOCITY = 50;
  float _TURN_SPEED = 0.5;
  
  float _MAX_DIST_TO_DASH = 50;
  float _MAX_ANGLE_TO_DASH = PI/4;
  float _DASH_FORCE = 500;
  float _DASH_RELOAD = 3;
  float dashTimer = 0;
  boolean canDash = true;
}
