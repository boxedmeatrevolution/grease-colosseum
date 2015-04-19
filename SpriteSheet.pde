
class SpriteSheet {
  
  PImage[] sprites;
  
  SpriteSheet (PImage[] _sprites) {
    sprites = _sprites;
  }
  
  void drawSprite (int index, int xPos, int yPos, int xRad, int yRad) {
    image(sprites[index], xPos, yPos, xRad, yRad);
  }
}

// A class for automaticaly animating 
class Animation {
  SpriteSheet sheet;
  int[] sprites;
  float time;
  
  int curr;
  float lastCall;
  
  Animation (SpriteSheet _sheet, float _time, int... _sprites) {
    sheet = _sheet;
    time = _time;
    sprites = _sprites;
    
    curr = 0;
  }
  
  //Draws and updates the animation.
  void draw (int xPos, int yPos, int xRad, int yRad) {
    sheet.drawSpriteSheet(sprites[curr] ,xPos, yPos, xRad, yRad);
    
    // Only move to the next frame when enough time has passed
    float x = Date.now() / 1000;
    if (time >= (lastCall - x)) {
      x++;
      x %= sprites.length;
      lastCall = 0;
    }
  }
  
  void reset () {
    curr = 0;
  }
}

/* Loads a SpriteSheet from image at filename with x colums of sprites and y rows of sprites. */
SpriteSheet loadSpriteSheet (String filename, int x, int y) {
  PImage img = loadImage(filename);
  
  PImage[] sprites = new PImage[x*y];
  
  int xSize = img.width / x;
  int ySize = img.height / y;
  
  int a = 0;
  for (int j = 0; j < y; j++) {
    for (int i = 0; i < x; i++) {
      sprites[a++] = img.get(i*xSize,j*ySize, xSize, ySize);
    }
  }
  return new SpriteSheet(sprites);
}






