/* @pjs preload="./assets/spike_wall.png" */
PImage spikeWallImage;

float SPIKE_RADIUS;

class SpikeWall extends Entity {
  
  SpikeWall() {
  }
  
  void create() {
    super.create();
    spikeWallImage = loadImage("./assets/spike_wall.png");
    SPIKE_RADIUS = width / 2 - 32;
    /*spikeGraphics = createGraphics(width / 2, height);
    int nSpikes = 500;
    float a = width / 2;
    float b = height / 2;
    float centerX = width / 2;
    float centerY = height / 2;
    spikeGraphics.beginDraw();
    spikeGraphics.beginShape();
    spikeGraphics.vertex(centerX, centerY + b);
    for (int i = 0; i < nSpikes / 2; ++i) {
      float angle = TAU / nSpikes * i + HALF_PI;
      float distance = sqrt(sq(a * cos(angle)) + sq(b * sin(angle)));
      if (i % 2 == 0) {
        distance -= 32;
      }
      spikeGraphics.vertex(distance * cos(angle) + centerX, distance * sin(angle) + centerY);
    }
    spikeGraphics.vertex(centerX - a, centerY - b);
    spikeGraphics.vertex(centerX - a, centerY + b);
    spikeGraphics.endShape(CLOSE);
    spikeGraphics.endDraw();*/
  }
  
  void destroy() {
    super.destroy();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
  }
  
  void render() {
    super.render();
    image(spikeWallImage, 0, 0);
    image(outline, 0, 0);
    //image(spikeGraphics, 0, 0);
  }
  
  int depth() {
    return -90;
  }
  
  //PGraphics spikeGraphics;
  
}

