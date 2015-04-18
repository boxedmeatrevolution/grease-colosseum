class PhysicsCollider extends Collider {
  PhysicsCollider(float x_, float y_, float mass_, float radius_, float friction_) {
    super(x_, y_, radius_, friction_);
    mass = mass_;
    kinematic = false;
  }
  
  void onCollision(Collider cOther, boolean wasHandled) {
    super.onCollision(cOther, wasHandled);
    if (wasHandled) {
      return;
    }
    if (cOther instanceof PhysicsCollider) {
      PhysicsCollider other = (PhysicsCollider) cOther;
      
      float deltaX = x - other.x;
      float deltaY = y - other.y;
      float deltaVelocityX = velocityX - other.velocityX;
      float deltaVelocityY = velocityY - other.velocityY;
      
      if (deltaX * deltaVelocityX + deltaY * deltaVelocityY > 0) {
        return;
      }
      
      float dotProduct = deltaX * deltaVelocityX + deltaY * deltaVelocityY;
      float distanceSqr = deltaX * deltaX + deltaY * deltaY;
      
      float massFactor1 = 2 * other.mass / (mass + other.mass);
      float massFactor2 = 2 * mass / (mass + other.mass);
      
      if (kinematic) {
        massFactor1 = 0;
        massFactor2 = 2;
      }
      else if (other.kinematic) {
        massFactor1 = 2;
        massFactor2 = 2;
      }
      
      float factor1 = massFactor1 * dotProduct / distanceSqr;
      float factor2 = massFactor2 * dotProduct / distanceSqr;
      
      velocityX -= factor1 * deltaX;
      velocityY -= factor1 * deltaY;
      
      other.velocityX += factor2 * deltaX;
      other.velocityY += factor2 * deltaY;
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
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
  }
  
  float mass;
  boolean kinematic;
  
}

