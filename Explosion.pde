class Explosion extends ContinuousHarmful {
  
  Explosion(float x_, float y_, float maxRadius_) {
    super(x_, y_, 0, 0, 0.5);
    maxRadius = maxRadius_;
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
      radius += growthRate * delta;
      if (radius > maxRadius) {
        removeEntity(this);
      }
    }
  }
  
  void render() {
    super.render();
    fill(color(255, 255, 0));
    ellipse(x, y, 2 * radius, 2 * radius);
    fill(255);
  }
  
  float maxRadius;
  float growthRate = 250;
  
}

