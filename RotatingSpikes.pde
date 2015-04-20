class RotatingSpikes extends Spikes {
  
  float centerX; 
  float centerY;
  float spinRadius;
  float spinSpeed;
  
  float angle = 0;
  
  RotatingSpikes (float _x, float _y, float _radius, float offsetAngle_, float _spinRadius, float _spinSpeed, float _nSpikes) {
    super(_x + _spinRadius * cos(offsetAngle_), _y - _spinRadius * sin(offsetAngle_), _radius, _nSpikes);
    centerX = _x;
    centerY = _y;
    spinRadius = _spinRadius;
    spinSpeed = _spinSpeed;
    angle = offsetAngle_;
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
  }
  
  void create() {
    super.create();
  }
  
  void destroy() {
    super.destroy();
  }
  
  void update (int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      angle += spinSpeed * delta;
      
      x = centerX + spinRadius*cos(angle);
      y = centerY - spinRadius*sin(angle);
      velocityX = -spinSpeed * spinRadius * sin(angle);
      velocityY = spinSpeed * spinRadius * cos(angle);
    }
  }
  
  void render () {
    super.render();
  }
  
  int depth () {
    return -70;
  }
}
