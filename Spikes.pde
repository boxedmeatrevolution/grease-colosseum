class Spikes extends Harmful {
  
  Spikes(float x_, float y_, float radius_, int nSpikes_) {
    super(x_, y_, 10, radius_, 500, 5);
    nSpikes = nSpikes_;
    rotationSpeed = random(-1.0f, 1.0f);
    
    shape = createGraphics(radius * 2, radius * 2);
    shape.beginDraw();
    shape.beginShape();
    for (int i = 0; i < nSpikes; ++i) {
      float distance = i % 2 == 0 ? radius : radius * 0.5;
      float angle = TAU / nSpikes * i;
      shape.vertex(radius + distance * cos(angle), radius - distance * sin(angle));
    }
    shape.endShape(CLOSE);
    shape.endDraw();
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
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      offsetAngle += rotationSpeed * delta;
    }
  }
  
  void render() {
    super.render();
    translate(x, y);
    rotate(offsetAngle);
    image(shape, - radius, - radius);
    rotate(-offsetAngle);
    translate(-x, -y);
  }
  
  int depth() {
    return -70;
  }
  
  PGraphics shape;
  
  int nSpikes;
  float offsetAngle = 0;
  float rotationSpeed;
  
}

