class Barrel extends PhysicsCollider {
  
  Barrel(float x_, float y_) {
    super(x_, y_, 1, 12, 500);
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
    triggered = true;
  }
  
  void create() {
    super.create();
  }
  
  void destroy() {
    super.destroy();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (triggered) {
      timer += delta;
      if (timer > 1.5) {
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
    fill(color(50, 120, 50));
    ellipse(x, y, 2 * radius, 2 * radius);
    fill(255);
  }
  
  float timer = 0;
  boolean triggered = false;
  
}

