class Barrel extends PhysicsCollider {
  
  Barrel(float x_, float y_) {
    super(x_, y_, 1, 16, 500);
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
    if (other instanceof Harmful || other instanceof ContinuousHarmful) {
      explode();
    }
  }
  
  void create() {
    super.create();
    if (barrelSheet == null) {
      barrelSheet = loadSpriteSheet("./assets/barrel.png", 1, 1, 32, 32);
      flamingBarrelSheet = loadSpriteSheet("./assets/flaming_barrel.png", 3, 1, 32, 32);
    }
    barrelAnimation = new Animation(barrelSheet, 1, 0);
    flamingBarrelAnimation = new Animation(flamingBarrelSheet, 0.2, 0, 1, 2);
  }
  
  void destroy() {
    super.destroy();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      barrelAnimation.update(delta);
      flamingBarrelAnimation.update(delta);
      if (triggered) {
        timer += delta;
        if (timer > 1.5) {
          addEntity(new Explosion(x, y));
          for (int i = 0; i < 5; ++i) {
            Flame particle = new Flame(x, y);
            float velocity = random(0, 400);
            float angle = random(0, TAU);
            particle.velocityX = velocity * cos(angle);
            particle.velocityY = -velocity * sin(angle);
            addEntity(particle);
          }
          removeEntity(this);
        }
      }
      if (touchingFire(x, y, radius)) {
        explode();
      }
    }
  }
  
  void render() {
    super.render();
    if (triggered) {
      flamingBarrelAnimation.drawAnimation(x - 16, y - 16, 32, 32);
    }
    else {
      barrelAnimation.drawAnimation(x - 16, y - 16, 32, 32);
    }
  }
  
  int depth() {
    return -70;
  }
  
  void explode () {
    triggered = true;
  }
  
  float timer = 0;
  boolean triggered = false;
  
  Animation barrelAnimation;
  Animation flamingBarrelAnimation;
  
}

SpriteSheet barrelSheet;
SpriteSheet flamingBarrelSheet;

