class Bomb extends PhysicsCollider {
  Bomb(float x_, float y_) {
    super(x_, y_, 1, 8, 500);
  }
  
  void create() {
    super.create();
    if (bombSheet == null) {
      bombSheet = loadSpriteSheet("./assets/bomb.png", 3, 1, 16, 16);
    }
    bombAnimation = new Animation(bombSheet, 0.2, 0, 1, 2);
  }
  
  void destroy() {
    super.destroy();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      bombAnimation.update(delta);
      timer += delta;
      tickTimer -= delta;
      if (tickTimer < 0) {
        tickTimer = 0.75;
        sounds["bombTick"].play();
      }
      if (timer > 3) {
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
  }
  
  void render() {
    super.render();
    bombAnimation.drawAnimation(x - radius, y - radius, 16, 16);
  }
  
  int depth() {
    return -70;
  }
  
  float timer = 0;
  float tickTimer = 0.75;
  
  Animation bombAnimation;
  
}

SpriteSheet bombSheet;

