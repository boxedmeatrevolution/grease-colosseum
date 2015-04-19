class EnemyEntity extends PhysicsCollider{
  EnemyEntity(float x_, float y_, float mass_, float radius_, float friction_, 
              int value_, float hp_, float facingDirection_, float acceleration_,
              float maxVelocity_) {
    super(x_, y_, mass_, radius_, friction_);
    value = value_;
    hp = hp_;
    facingDirection = facingDirection_;
    acceleration = acceleration_;
    maxVelocity = maxVelocity_;
  }
  
  void onCollision(Collider cOther, boolean wasHandled) {
    super.onCollision(cOther, wasHandled);
    if (cOther instanceof Harmful) {
      hp -= ((Harmful) cOther).damage;
    }
    if (cOther instanceof ContinuousHarmful) {
      hp -= ((ContinuousHarmful) cOther).damage * timeDelta;
    }
  }
  
  void create() {
    super.create();
  }
  
  void destroy() {
    super.destroy();
  }
  
  void render() {
    super.render();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      if (hp <= 0) {
        addEntity(new DeadBody(x, y, velocityX, velocityY, radius));
        score += value;
        removeEntity(this);
      }
      int nFires = touchingFire(x, y, radius);
      if (nFires <= 2) {
        heat = max(heat - 1 * delta, 0);
      }
      else {
        heat += nFires * 1 * delta;
      }
      
      if (heat > 1) {
        hp -= 1 * delta;
      }
    }
  }
  
  int value;
  float hp;
  float facingDirection;
  float acceleration;
  float maxVelocity;
  float heat = 0;
}
