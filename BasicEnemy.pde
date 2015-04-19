class BasicEnemy extends EnemyEntity{
  BasicEnemy(float x_, float y_, float facingDirection_) {
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
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      walkTowardsPlayer(delta);
      turnTowardsPlayer(delta);
    }
  }

  //Basic Enemy properties
  float _MASS = 1;
  float _RADIUS = 16;
  int _VALUE = 5;
  float _HP = 1;
  float _ACCELERATION = 1200;
  float _GREASE_ACCELERATION = 200;
  float _FRICTION = 600;
  float _MAXVELOCITY = 50;
  float _TURN_SPEED = 1;
}
