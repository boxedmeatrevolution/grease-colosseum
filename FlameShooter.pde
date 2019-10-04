class FlameShooter extends PhysicsCollider {
  int facing;
  boolean isFiring = false;
  float firingTime = 0;
  FlameShooter(float x_, float y_, int facingDirection_) {
    super(x_, y_, 10, 12, 500);
    facingDirection = facingDirection_ * TAU / 4;
    facing = facingDirection_ % 4;
    /*shape = createGraphics(radius * 2, radius * 2);
    shape.beginDraw();
    shape.beginShape();
    int nSpikes = 6;
    for (int i = 0; i < nSpikes; ++i) {
      float distance = i == 0 ? radius : radius * 0.5;
      float angle = TAU / nSpikes * i + facingDirection;
      shape.vertex(radius / 2 + distance * cos(angle), radius / 2 - distance * sin(angle));
    }
    shape.endShape(CLOSE);
    shape.endDraw();*/
  }
  
  void onCollision(Collider cOther, boolean wasHandled) {
    super.onCollision(cOther, wasHandled);
  }
  
  void create() {
    super.create();
    if (flameShooterSheet == null) {
      flameShooterSheet = loadSpriteSheet("./assets/flame_shooter.png", 4, 1, 24, 24);
    }
  }
  
  void destroy() {
    super.destroy();
  }
  
  void render() {
    super.render();
    flameShooterSheet.drawSprite(facing, x - 12, y - 12, 24, 24);
    //image(shape, x - radius / 2, y - radius / 2);
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      if (isFiring) {
        Flame particle = new Flame(x, y);
        float velocity = SHOOT_VELOCITY + random(-SHOOT_VELOCITY_RANDOM, +SHOOT_VELOCITY_RANDOM);
        float angle = facingDirection + random(-SHOOT_ANGLE_RANDOM, +SHOOT_ANGLE_RANDOM);
        particle.velocityX = velocity * cos(angle);
        particle.velocityY = -velocity * sin(angle);
        addEntity(particle);
      }
      else {
        firingTime += delta;
        if (firingTime > 2) {
          isFiring = true;
        }
      }
    }
  }
  
  int depth() {
    return -70;
  }
  
  //PGraphics shape;
  float facingDirection;
  
  float SHOOT_VELOCITY = 300;
  float SHOOT_VELOCITY_RANDOM = 100;
  float SHOOT_ANGLE_RANDOM = 0.25;
}

SpriteSheet flameShooterSheet;

