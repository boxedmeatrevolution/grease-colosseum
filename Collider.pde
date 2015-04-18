class Collider extends Entity {
  
  Collider(float x_, float y_, float radius_) {
    x = x_;
    y = y_;
    radius = radius_;
  }
  
  void onCollision(Collider other) {}
  
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
    }
  }
  
  int depth() {
    return 0;
  }
  
  boolean collides(Collider other) {
    float deltaX = x - other.x;
    float deltaY = y - other.y;
    float distanceSqr = deltaX * deltaX + deltaY * deltaY;
    float totalRadius = radius + other.radius;
    return distanceSqr <= totalRadius * totalRadius;
  }
  
  boolean intersects(float pointX, float pointY) {
    float deltaX = pointX - x;
    float deltaY = pointY - y;
    float distanceSqr = deltaX * deltaX + deltaY * deltaY;
    return distanceSqr <= radius * radius;
  }
  
  float x;
  float y;
  float velocityX;
  float velocityY;
  float radius;
}

