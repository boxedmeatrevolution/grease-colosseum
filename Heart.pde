class Heart extends PhysicsCollider {
  Heart (float x_, float y_) {
    super (x_, y_, 200, 40, 50);
  }
  
  void onCollision(Collider cOther, boolean wasHandled) {
    super.onCollision(cOther, wasHandled);
    if (cOther instanceof Player){
      removeEntity(this);
    }
  }
  
  void create() {
    super.create();
  }
  
  void destroy() {
    super.destroy();
  }
  
  void render() {
    super.render();
    image(heartImage, x, y);
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
  }
}

PImage heartImage;
