class Spikes extends Harmful {
  
  Spikes(float x_, float y_, float radius_, int nSpikes_) {
    super(x_, y_, 100000, radius_, 500, 5);
    nSpikes = nSpikes_;
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
  }
  
  void render() {
    super.render();
    beginShape();
    for (int i = 0; i < nSpikes; ++i) {
      float distance = i % 2 == 0 ? radius : radius * 0.5;
      float angle = TAU / nSpikes * i;
      vertex(x + distance * cos(angle), y - distance * sin(angle));
    }
    endShape(CLOSE);
  }
  
  int depth() {
    return -1;
  }
  
  int nSpikes;
  
}

