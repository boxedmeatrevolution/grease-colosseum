class FlameThrower extends Moving {
  
  FlameThrower(float x_, float y_) {
    super(x_, y_, FLAMETHROWER_FRICTION);
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
    super.update(state, delta);
    if (phase == 0) {
      applyFlameToMatrix(this);
      if (!isMoving()) {
        removeEntity(this);
      }
    }
  }
  boolean isMoving() {
    // Is the flame still flying through the air?
    if(abs(velocityX) < 0.1 & abs(velocityY) < 0.1) {
        return false;
    }
    return true;
  }
  
  int state = 0;
  float radius = 4;
  
  int MOVING_STATE = 0;
  int GROUND_STATE = 1;
  
  float FLAMETHROWER_FRICTION = 500;
}

