class RotatingSpikes extends Spikes {
  
  int centerX; 
  int centerY;
  int spinRadius;
  int spinSpeed;
  
  float angle = 0;
  
  RotatingSpikes (int _x, int _y, int _radius, int _spinRadius, int _spinSpeed, int _nSpikes) {
    super(_x + _spinRadius, _y, _radius, _nSpikes);
    centerX = _x;
    centerY = _y;
    spinRadius = _spinRadius;
    spinSpeed = _spinSpeed;
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
    
    angle += spinSpeed * delta;
    
    x = centerX + spinRadius*cos(angle);
    y = centerY + spinRadius*sin(angle);
  }
  
  void render () {
    super.render();
  }
  
  int depth () {
    return super.depth();
  }
}
