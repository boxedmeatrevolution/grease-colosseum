class Blood extends Moving {
  
  Blood(float x_, float y_) {
    super(x_, y_, GREASE_FRICTION);
  }
  
  float radius = 8;
  
  void create() {
    super.create();
    if (bloodImage == null) {
      bloodImage = loadImage("./assets/blood_particle.png");
    }
  }
  void destroy() {
    super.destroy();
  }
  void render() {
    super.render();
    if (radius > 2) {
      greaseGraphics.beginDraw();
      greaseGraphics.image(bloodImage, x - radius, y - radius, 2 * radius, 2 * radius);
      greaseGraphics.endDraw();
    }
    //image(bloodImage, x - 4, y - 4, 8, 8);
  }
  void update(int phase, float delta) {
    super.update(state, delta);
    if (phase == 0) {
      radius -= 16 * delta;
      if (radius < 0) {
        radius = 0;
      }
      if(state == MOVING_STATE) {
        if(!isMoving()) {
          state = GROUND_STATE;
        }
      } else {
        removeEntity(this);
      }
    }
  }
  boolean isMoving() {
    // Is the grease still flying through the air?
    if(abs(velocityX) < 0.1 & abs(velocityY) < 0.1) {
        return false;
    }
    return true;
  }
  
  int depth() {
    return 0;
  }
  
  int state = 0;
  
  int MOVING_STATE = 0;
  int GROUND_STATE = 1;
  
  float GREASE_FRICTION = 500;
}

PImage bloodImage;

