class Player extends PhysicsCollider {
  Player(float x_, float y_) {
    super(x_, y_, 1, 16, 600);
  }
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
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
      facingDirection = atan2(-(mouseY - y), mouseX - x);
      if (leftKeyPressed && velocityX > -MAX_VELOCITY) {
        velocityX -= ACCELERATION * delta;
      }
      if (rightKeyPressed && velocityX < MAX_VELOCITY) {
        velocityX += ACCELERATION * delta;
      }
      if (upKeyPressed && velocityY > -MAX_VELOCITY) {
        velocityY -= ACCELERATION * delta;
      }
      if (downKeyPressed && velocityY < MAX_VELOCITY) {
        velocityY += ACCELERATION * delta;
      }
      if (shootKeyPressed) {
        Grease particle = new Grease(x, y);
        float velocity = SHOOT_VELOCITY + random(-SHOOT_VELOCITY_RANDOM, +SHOOT_VELOCITY_RANDOM);
        float angle = facingDirection + random(-SHOOT_ANGLE_RANDOM, +SHOOT_ANGLE_RANDOM);
        particle.velocityX = velocity * cos(angle);
        particle.velocityY = -velocity * sin(angle);
        addEntity(particle);
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
  float MAX_VELOCITY = 150;
  float SHOOT_VELOCITY = 250;
  float SHOOT_VELOCITY_RANDOM = 250;
  float SHOOT_ANGLE_RANDOM = 0.05;
}

