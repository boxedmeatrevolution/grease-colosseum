class Explosion extends ContinuousHarmful {
  
  Explosion(float x_, float y_) {
    super(x_, y_, 0, 0, 10);
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
  }
  
  void create() {
    super.create();
    if (explosionSheet == null) {
      explosionSheet = loadSpriteSheet("./assets/explosion.png", 16, 1, 64, 64);
    }
    explosionAnimation = new Animation(explosionSheet, 0.04, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15);
    explosionAnimation.loop = false;
    sounds["explosion"].play();
  }
  
  void destroy() {
    super.destroy();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      explosionAnimation.update(delta);
      timer += delta;
      radius += growthRate * delta;
      if (radius > maxRadius) {
        radius = maxRadius;
      }
      if (timer > 0.64) {
        removeEntity(this);
      }
    }
  }
  
  void render() {
    super.render();
    explosionAnimation.drawAnimation(x - 32, y - 32, 64, 64);
  }
  
  int depth() {
    return -110;
  }
  
  float maxRadius = 64;
  float growthRate = 640;
  float timer = 0.0f;
  
  Animation explosionAnimation;
  
}

SpriteSheet explosionSheet;

