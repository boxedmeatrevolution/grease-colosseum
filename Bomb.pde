class Bomb extends PhysicsCollider {
  Bomb(float x_, float y_) {
    super(x_, y_, 1, 8, 500);
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
      timer += delta;
      if (timer > 3) {
        addEntity(new Explosion(x, y, 64));
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
    ellipse(x, y, 2 * radius, 2 * radius);
  }
  
  float timer = 0;
  
}

