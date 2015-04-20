class DeadBody extends Moving {
  
  DeadBody(float x_, float y_, float velocityX_, float velocityY_, float radius_) {
    super(x_, y_, 1000);
    velocityX = velocityX_;
    velocityY = velocityY_;
    radius = radius_;
  }
  
  void create() {
    super.create();
  }
  
  void destroy() {
    super.destroy();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
  }
  
  void render() {
    super.render();
    /*fill(color(20, 20, 20));
    ellipse(x, y, 2 * radius, 2 * radius);*/
  }
  
  int depth() {
    return -10;
  }
  
  float radius;
  
}

