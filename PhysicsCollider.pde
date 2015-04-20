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
      
      float dotProduct = deltaX * deltaVelocityX + deltaY * deltaVelocityY;
      float distanceSqr = deltaX * deltaX + deltaY * deltaY;
      
      float massFactor1 = 2 * other.mass / (mass + other.mass);
      float massFactor2 = 2 * mass / (mass + other.mass);
      
      if (dotProduct > 0) {
        return;
      }
      
      if (sq(deltaVelocityX) + sq(deltaVelocityY) > 50 * 50) {
        sounds["collision"].play();
      }
      
      if (kinematic) {
        massFactor1 = 0;
        massFactor2 = 2;
      }
      else if (other.kinematic) {
        massFactor1 = 2;
        massFactor2 = 0;
      }
      
      float factor1 = massFactor1 * dotProduct / distanceSqr;
      float factor2 = massFactor2 * dotProduct / distanceSqr;
      
      if (!kinematic) {
        velocityX -= factor1 * deltaX;
        velocityY -= factor1 * deltaY;
      }
      
      if (!other.kinematic) {
        other.velocityX += factor2 * deltaX;
        other.velocityY += factor2 * deltaY;
      }
    }
  }
  
  void hitEdge() {
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
      float centerX = width / 2;
      float centerY = height / 2;
      float deltaX = x - centerX;
      float deltaY = y - centerY;
      float distanceSq = sq(deltaX) + sq(deltaY);
      float distance = sqrt(distanceSq);
      if (distanceSq > sq(SPIKE_RADIUS)) {
        x = SPIKE_RADIUS * deltaX / distance + centerX;
        y = SPIKE_RADIUS * deltaY / distance + centerY;
        float nx = -deltaX / distance;
        float ny = -deltaY / distance;
        float tx = -ny;
        float ty = nx;
        
        float iy = nx;
        float ix = tx;
        
        float jy = ny;
        float jx = tx;
        
        float transformedY = velocityX * nx + velocityY * ny;
        float transformedX = velocityX * tx + velocityY * ty;
        
        if (transformedY < 0) {
          transformedY = -transformedY;
        }
        
        velocityX = transformedX * ix + transformedY * iy;
        velocityY = transformedX * jx + transformedY * jy;
        
        hitEdge();
      }
    }
  }
  
  float mass;
  boolean kinematic;
  
}

