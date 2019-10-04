class Pillar extends PhysicsCollider {
  
  int frame = 0;
  
  Pillar(float x_, float y_, float radius_) {
    super(x_, y_, 1, radius_, 1);
    kinematic = true;
    frame = floor(random(0, 2.999));
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
  }
  
  void create() {
    super.create();
    if (pillarSheet == null) {
      pillarSheet = loadSpriteSheet("./assets/pillar.png", 3, 1, 128, 128);
    }
  }
  
  void destroy() {
    super.destroy();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
  }
  
  void render() {
    super.render();
    pillarSheet.drawSprite(frame, x - radius, y - radius, 2 * radius, 2 * radius);
  }
  
  int depth() {
    return -70;
  }
  
}

SpriteSheet pillarSheet;

