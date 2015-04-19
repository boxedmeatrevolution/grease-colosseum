class Player extends PhysicsCollider {
  Player(float x_, float y_) {
    super(x_, y_, 1, 16, FRICTION);
  }
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
    if (other instanceof Harmful || other instanceof ContinuousHarmful) {
      addEntity(new DeadBody(x, y, velocityX, velocityY, radius));
      removeEntity(this);
      isPlayerDead = true;
    }
  }
  void create() {
    super.create();
  }
  void destroy() {
    super.destroy();
  }
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      boolean isOnGrease = touchingGrease(x, y, radius);
      facingDirection = atan2(-(mouseY - y), mouseX - x);
      /*if (isOnGrease) {
        friction = 0;
      }
      else {
        friction = FRICTION;
      }*/
      float acceleration = ACCELERATION;//isOnGrease ? GREASE_ACCELERATION : ACCELERATION;
      float maxVelocity = isOnGrease ? MAX_VELOCITY : MAX_VELOCITY / 10;
      if (leftKeyPressed && velocityX > -maxVelocity) {
        velocityX -= acceleration * delta;
      }
      if (rightKeyPressed && velocityX < maxVelocity) {
        velocityX += acceleration * delta;
      }
      if (upKeyPressed && velocityY > -maxVelocity) {
        velocityY -= acceleration * delta;
      }
      if (downKeyPressed && velocityY < maxVelocity) {
        velocityY += acceleration * delta;
      }
      if (shootKeyPressed) {
        Grease particle = new Grease(x, y);
        float velocity = SHOOT_VELOCITY + random(-SHOOT_VELOCITY_RANDOM, +SHOOT_VELOCITY_RANDOM);
        float angle = facingDirection + random(-SHOOT_ANGLE_RANDOM, +SHOOT_ANGLE_RANDOM);
        particle.velocityX = velocity * cos(angle);
        particle.velocityY = -velocity * sin(angle);
        addEntity(particle);
      }
      if (secondaryShootKeyPressed && canFireSecondary) {
        Flame particle = new Flame(x, y);
        float deltaX = mouseX - x;
        float deltaY = mouseY - y;
        float distance = sqrt(deltaX * deltaX + deltaY * deltaY);
        float velocity = sqrt(2 * particle.friction * distance);
        particle.velocityX = velocity * cos(facingDirection);
        particle.velocityY = -velocity * sin(facingDirection);
        addEntity(particle);
        canFireSecondary = false;
      }
      if (!canFireSecondary) {
        secondaryFireTimer += delta;
        if (secondaryFireTimer > SECONDARY_RELOAD) {
          secondaryFireTimer = 0;
          canFireSecondary = true;
        }
      }
      
      int nFires = touchingFire(x, y, radius);
      if (nFires <= 2) {
        heat = max(heat - 1 * delta, 0);
      }
      else {
        heat += nFires * 1 * delta;
      }
      
      if (heat > 1) {
        addEntity(new DeadBody(x, y, velocityX, velocityY, radius));
        removeEntity(this);
        isPlayerDead = true;
      }
    }
  }
  void render() {
    super.render();
    ellipse(x, y, 2 * radius, 2 * radius);
    line(x, y, x + radius * cos(facingDirection), y - radius * sin(facingDirection));
  }
  int depth() {
    return -10;
  }
  float facingDirection = 0;
  float ACCELERATION = 1200;
  float GREASE_ACCELERATION = 200;
  float FRICTION = 600;
  float MAX_VELOCITY = 150;
  float secondaryFireTimer = 0;
  float heat = 0;
  boolean canFireSecondary = true;
  
  float SHOOT_VELOCITY = 300;
  float SHOOT_VELOCITY_RANDOM = 100;
  float SHOOT_ANGLE_RANDOM = 0.25;
  
  float SECONDARY_RELOAD = 3;
}

