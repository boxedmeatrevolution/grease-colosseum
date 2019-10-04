class DeadBody extends Moving {
  
  DeadBody(float x_, float y_, float velocityX_, float velocityY_, float radius_) {
    super(x_, y_, 1000);
    velocityX = velocityX_;
    velocityY = velocityY_;
    radius = radius_;
  }
  
  void create() {
    super.create();
    if (deathSheet == null) {
      deathSheet = loadSpriteSheet("./assets/death.png", 10, 1, 32, 64);
    }
    deathAnimation = new Animation(deathSheet, 0.1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9);
  }
  
  void destroy() {
    super.destroy();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    deathAnimation.update(delta);
  }
  
  void render() {
    super.render();
    deathAnimation.drawAnimation(x - 16, y - 16 - 32, 32, 64);
  }
  
  int depth() {
    return -10;
  }
  
  float radius;
  Animation deathAnimation;
  
}

SpriteSheet deathSheet;

