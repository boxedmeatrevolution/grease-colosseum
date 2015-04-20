// Similar to the Grease class, but calls applyFlameToMatrix instead
class Flame extends Moving {
  
  Flame(float x_, float y_) {
    super(x_, y_, FLAME_FRICTION);
  }
  
  void create() {
    super.create();
  }
  void destroy() {
    super.destroy();
  }
  void render() {
    noStroke();
    smallFireAnimations[0].drawAnimation(x - 4, y - 4, 8, 8);
    /*fill(FLAME_COLOR);
    ellipse(x, y, 2 * radius, 2 * radius);
    fill(255);
    stroke(0);*/
  }
  void update(int phase, float delta) {
    super.update(state, delta);
    if (phase == 0) {
      if(state == MOVING_STATE) {
        if(!isMoving()) {
          state = GROUND_STATE;
          applyFlameToMatrix(this);
        }
      } else {
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
  
  int depth() {
    return 0;
  }
  
  int state = 0;
  float radius = 4;
  
  int MOVING_STATE = 0;
  int GROUND_STATE = 1;
  
  float FLAME_FRICTION = 500;
}

color FLAME_COLOR = color(125, 20, 0);

