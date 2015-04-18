class Moving extends Entity {
  
  Moving(float x_, float y_, float friction_) {
    x = x_;
    y = y_;
    friction = friction_;
  }
  
  void create() {
    super.create();
  }
  
  void destroy() {
    super.destroy();
  }
  
  void render() {
    super.render();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      x += velocityX * delta;
      y += velocityY * delta;
      if (velocityX > friction * delta) {
        velocityX -= friction * delta;
      }
      else if (velocityX < -friction * delta) {
        velocityX += friction * delta;
      }
      else {
        velocityX = 0.0f;
      }
      
      if (velocityY > friction * delta) {
        velocityY -= friction * delta;
      }
      else if (velocityY < -friction * delta) {
        velocityY += friction * delta;
      }
      else {
        velocityY = 0.0f;
      }
    }
  }
  
  float friction;
  float x;
  float y;
  float velocityX;
  float velocityY;
  
}
