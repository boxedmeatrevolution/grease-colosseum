class Grease extends Moving {
  
  Grease(float x_, float y_) {
    super(x_, y_, GREASE_FRICTION);
  }
  
  void create() {
    super.create();
    if (greaseImage == null) {
      greaseImage = loadImage("./assets/grease_particle.png");
    }
  }
  void destroy() {
    super.destroy();
  }
  void render() {
    super.render();
    image(greaseImage, x - radius, y - radius, 2 * radius, 2 * radius);
    /*noStroke();
    fill(GREASE_COLOR);
    ellipse(x, y, 2 * radius, 2 * radius);
    fill(255);
    stroke(0);*/
  }
  void update(int phase, float delta) {
    super.update(state, delta);
    if (phase == 0) {
      radius += 12 * delta;
      if(state == MOVING_STATE) {
        if(!isMoving()) {
          state = GROUND_STATE;
          applyGreaseToMatrix(this);
        }
      } else {
        removeEntity(this);
      }
    }
  }
  boolean isMoving() {
    // Is the grease still flying through the air?
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
  
  float GREASE_FRICTION = 500;
}

PImage greaseImage;
PImage sootImage;

color GREASE_COLOR = color(173, 165, 50);

class FireEffect extends Entity {
  FireEffect() {
  }
  void create() {
    super.create();
    sootImage = loadImage("./assets/soot.png");
    largeFireSheet = loadSpriteSheet("./assets/large_fire.png", 4, 1, 24, 24);
    mediumFireSheet = loadSpriteSheet("./assets/medium_fire.png", 7, 1, 16, 16);
    smallFireSheet = loadSpriteSheet("./assets/small_fire.png", 5, 1, 8, 8);
    
    float time = 0.3;
    
    largeFireAnimations = new Animation[] {
      new Animation(largeFireSheet, time, 0, 1, 2, 3),
      new Animation(largeFireSheet, time, 1, 2, 3, 0),
      new Animation(largeFireSheet, time, 2, 3, 0, 1),
      new Animation(largeFireSheet, time, 3, 0, 1, 2)
    };
    mediumFireAnimations = new Animation[] {
      new Animation(mediumFireSheet, time, 0, 1, 2, 3, 4, 5, 6),
      new Animation(mediumFireSheet, time, 1, 2, 3, 4, 5, 6, 0),
      new Animation(mediumFireSheet, time, 2, 3, 4, 5, 6, 0, 1),
      new Animation(mediumFireSheet, time, 3, 4, 5, 6, 0, 1, 2)
    };
    smallFireAnimations = new Animation[] {
      new Animation(smallFireSheet, time, 0, 1, 2, 3, 4),
      new Animation(smallFireSheet, time, 1, 2, 3, 4, 0),
      new Animation(smallFireSheet, time, 2, 3, 4, 0, 1),
      new Animation(smallFireSheet, time, 3, 4, 0, 1, 2)
    };
  }
  void destroy() {
    super.destroy();
  }
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      float fireLevel = min(totalFire / 2500.0f, 1.0f);
      sounds["fire"].volume = fireLevel;
      for (Animation animation : largeFireAnimations) {
        animation.update(delta);
      }
      for (Animation animation : mediumFireAnimations) {
        animation.update(delta);
      }
      for (Animation animation : smallFireAnimations) {
        animation.update(delta);
      }
    }
  }
  void render() {
    super.render();
    totalFire = 0;
    for (int i = 0; i < (int) (floor(greaseMatrix.length / 2)); ++i) {
      for (int j = 0; j < (int) (floor(greaseMatrix[0].length / 2)); ++j) {
        int nFire = 0;
        if (greaseMatrix[2 * i][2 * j] == FIRE) ++nFire;
        if (greaseMatrix[2 * i + 1][2 * j] == FIRE) ++nFire;
        if (greaseMatrix[2 * i][2 * j + 1] == FIRE) ++nFire;
        if (greaseMatrix[2 * i + 1][2 * j + 1] == FIRE) ++nFire;
        int animChoice = (i + j) % 4;
        totalFire += nFire;
        if (nFire == 1) {
          smallFireAnimations[animChoice].drawAnimation((2 * i + 1) * CELL_WIDTH - 4, (2 * j + 1) * CELL_HEIGHT - 4, 8, 8);
        }
        else if (nFire == 2 || nFire == 3) {
          mediumFireAnimations[animChoice].drawAnimation((2 * i + 1) * CELL_WIDTH - 8, (2 * j + 1) * CELL_HEIGHT - 8, 16, 16);
        }
        else if (nFire == 4) {
          largeFireAnimations[animChoice].drawAnimation((2 * i + 1) * CELL_WIDTH - 12, (2 * j + 1) * CELL_HEIGHT - 12, 24, 24);
        }
      }
    }
  }
  int depth() {
    return 90;
  }
  
  int totalFire;
}

class GreaseSurface extends Entity {
  void create() {
    super.create();
    initGreaseMatrix();
  }
  void destroy() {
    super.destroy();
  }
  void render() {
    super.render();
    image(greaseGraphics, 0, 0);
    /*for(int x = 0; x < greaseMatrix.length; x ++) {
      for(int y = 0; y < greaseMatrix[0].length; y ++) {
        if(greaseMatrix[x][y] == GREASE) {
          noStroke();
          fill(color(50, 50, 50));
          rect(x * CELL_WIDTH, y * CELL_HEIGHT, CELL_WIDTH, CELL_HEIGHT);
          fill(color(255, 255, 255));
          stroke();
        } else if(greaseMatrix[x][y] == FIRE) {
          noStroke();
          fill(color(100, 0, 0));
          rect(x * CELL_WIDTH, y * CELL_HEIGHT, CELL_WIDTH, CELL_HEIGHT);
          fill(color(255, 255, 255));
          stroke();
        }
      }
    }*/
  }
  void update(int phase, float delta) {
    super.update(phase, delta);
    if(phase == 0) {
      updateGreaseMatrix(delta);
    }
  }
  
  int depth() {
    return 100;
  }
}

// Underlying grid representing the grease
byte[][] greaseMatrix;

// Graphics that draws the grease
PGraphics greaseGraphics;


Animation[] largeFireAnimations;
Animation[] mediumFireAnimations;
Animation[] smallFireAnimations;

SpriteSheet largeFireSheet;
SpriteSheet mediumFireSheet;
SpriteSheet smallFireSheet;

// Dimensions of each grease grid cell
int CELL_WIDTH = 8;
int CELL_HEIGHT = 8;

byte NO_GREASE = 0;
byte GREASE = 1;
byte FIRE = 2;

float FLAMMABILITY = 1;
float EXTINGUISHABILITY = 0.5;

// Given the width and height of the game,
// create the underlying grid representing the grease
void initGreaseMatrix() {
  greaseMatrix = new byte[ceil(((float)width)/((float)CELL_WIDTH))][ceil(((float)height)/((float)CELL_HEIGHT))];
  greaseGraphics = createGraphics(width, height);
  greaseGraphics.noStroke();
  greaseGraphics.fill(0, 0, 0);
}

void updateGreaseMatrix(float delta) {
  for(int x = 0; x < greaseMatrix.length; x ++) {
    for(int y = 0; y < greaseMatrix[0].length; y ++) {
      if(greaseMatrix[x][y] == FIRE) {
        boolean hasGreaseNeighbour = false;
        int nFireNeighbours = 0;
        if(x > 0 && y > 0) {
          if (greaseMatrix[x - 1][y - 1] == GREASE) {
            hasGreaseNeighbour = true;
            if(random(0, 1) > 1 - delta * FLAMMABILITY) {
              createFire(x - 1, y - 1);
            }
          }
          else if (greaseMatrix[x - 1][y - 1] == FIRE) {
            ++nFireNeighbours;
          }
        }
        if(y > 0) {
          if (greaseMatrix[x][y - 1] == GREASE) {
            hasGreaseNeighbour = true;
            if(random(0, 1) > 1 - delta * FLAMMABILITY) {
              createFire(x, y - 1);
            }
          }
          else if (greaseMatrix[x][y - 1] == FIRE) {
            ++nFireNeighbours;
          }
        }
        if(x < greaseMatrix.length - 1 && y > 0) {
          if (greaseMatrix[x + 1][y - 1] == GREASE) {
            hasGreaseNeighbour = true;
            if(random(0, 1) > 1 - delta * FLAMMABILITY) {
              createFire(x + 1, y - 1);
            }
          }
          else if (greaseMatrix[x + 1][y - 1] == FIRE) {
            ++nFireNeighbours;
          }
        }
        if(x > 0) {
          if (greaseMatrix[x - 1][y] == GREASE) {
            hasGreaseNeighbour = true;
            if(random(0, 1) > 1 - delta * FLAMMABILITY) {
              createFire(x - 1, y);
            }
          }
          else if (greaseMatrix[x - 1][y] == FIRE) {
            ++nFireNeighbours;
          }
        }
        if(x < greaseMatrix.length - 1) {
          if (greaseMatrix[x + 1][y] == GREASE) {
            hasGreaseNeighbour = true;
            if(random(0, 1) > 1 - delta * FLAMMABILITY) {
              createFire(x + 1, y);
            }
          }
          else if (greaseMatrix[x + 1][y] == FIRE) {
            ++nFireNeighbours;
          }
        }
        if(x > 0 && y < greaseMatrix[0].length - 1) {
          if (greaseMatrix[x - 1][y + 1] == GREASE) {
            hasGreaseNeighbour = true;
            if(random(0, 1) > 1 - delta * FLAMMABILITY) {
              createFire(x - 1, y + 1);
            }
          }
          else if (greaseMatrix[x - 1][y + 1] == FIRE) {
            ++nFireNeighbours;
          }
        }
        if(y < greaseMatrix[0].length - 1) {
          if (greaseMatrix[x][y + 1] == GREASE) {
            hasGreaseNeighbour = true;
            if(random(0, 1) > 1 - delta * FLAMMABILITY) {
              createFire(x, y + 1);
            }
          }
          else if (greaseMatrix[x][y + 1] == FIRE) {
            ++nFireNeighbours;
          }
        }
        if(x < greaseMatrix.length - 1 && y < greaseMatrix[0].length - 1) {
          if (greaseMatrix[x + 1][y + 1] == GREASE) {
            hasGreaseNeighbour = true;
            if(random(0, 1) > 1 - delta * FLAMMABILITY) {
              createFire(x + 1, y + 1);
            }
          }
          else if (greaseMatrix[x + 1][y + 1] == FIRE) {
            ++nFireNeighbours;
          }
        }
        if (!hasGreaseNeighbour) {
          if (random(0, 1) > 1 - delta * EXTINGUISHABILITY * (8 - nFireNeighbours)) {
            greaseMatrix[x][y] = NO_GREASE;
          }
        }
      }
    }
  }
}

// Set the cell at x,y in the matrix on fire and create particle effect
void createFire(int x, int y) {
  if (x < 0 || x >= greaseMatrix.length || y < 0 || y > greaseMatrix[0].length) {
    return;
  }
  greaseMatrix[x][y] = FIRE;
  greaseGraphics.beginDraw();
  greaseGraphics.image(sootImage, x * CELL_WIDTH, y * CELL_HEIGHT, 12, 12);
  //greaseGraphics.ellipse(x * CELL_WIDTH, y * CELL_HEIGHT, CELL_WIDTH * sqrt(2), CELL_HEIGHT * sqrt(2));
  greaseGraphics.endDraw();
}

// Add the grease to the grease matrix
void applyGreaseToMatrix(Grease grease) {
  int topLeftX = floor((grease.x - grease.radius) / CELL_WIDTH);
  int topLeftY = floor((grease.y - grease.radius) / CELL_HEIGHT);
  int botRightX = ceil((grease.x + grease.radius) / CELL_WIDTH);
  int botRightY = ceil((grease.y + grease.radius) / CELL_HEIGHT);
  for(int x = topLeftX; x <= botRightX; x ++) {
    for(int y = topLeftY; y <= botRightY; y ++) {
      if (x >= 0 && x < greaseMatrix.length && y >= 0 && y < greaseMatrix.length) {
        greaseMatrix[x][y] = GREASE;
      }
    }
  }
  greaseGraphics.beginDraw();
  greaseGraphics.image(greaseImage, grease.x - grease.radius, grease.y - grease.radius, 2 * grease.radius, 2 * grease.radius);
  //greaseGraphics.ellipse(grease.x, grease.y, grease.radius * 2, grease.radius * 2);
  greaseGraphics.endDraw();
}

// Add the flame to the grease matrix
void applyFlameToMatrix(Flame flame) {
  int topLeftX = floor((flame.x - flame.radius) / CELL_WIDTH);
  int topLeftY = floor((flame.y - flame.radius) / CELL_HEIGHT);
  int botRightX = ceil((flame.x + flame.radius) / CELL_WIDTH);
  int botRightY = ceil((flame.y + flame.radius) / CELL_HEIGHT);
  for(int x = topLeftX; x <= botRightX; x ++) {
    for(int y = topLeftY; y <= botRightY; y ++) {
      if (x >= 0 && x < greaseMatrix.length && y >= 0 && y < greaseMatrix.length) {
        createFire(x, y);
      }
    }
  }
}

boolean touchingGrease(float x, float y, float radius) {
  int topLeftX = floor((x - radius) / CELL_WIDTH);
  int topLeftY = floor((y - radius) / CELL_HEIGHT);
  int botRightX = ceil((x + radius) / CELL_WIDTH);
  int botRightY = ceil((y + radius) / CELL_HEIGHT);
  for(int x = topLeftX; x <= botRightX; x ++) {
    for(int y = topLeftY; y <= botRightY; y ++) {
      if (x >= 0 && x < greaseMatrix.length && y >= 0 && y < greaseMatrix.length) {
        if(greaseMatrix[x][y] == GREASE) {
          return true;
        }
      }
    }  
  }
  return false;
}

int touchingFire(float x, float y, float radius) {
  int topLeftX = floor((x - radius) / CELL_WIDTH);
  int topLeftY = floor((y - radius) / CELL_HEIGHT);
  int botRightX = ceil((x + radius) / CELL_WIDTH);
  int botRightY = ceil((y + radius) / CELL_HEIGHT);
  int nFires = 0;
  for(int x = topLeftX; x <= botRightX; x ++) {
    for(int y = topLeftY; y <= botRightY; y ++) {
      if (x >= 0 && x < greaseMatrix.length && y >= 0 && y < greaseMatrix.length) {
        if(greaseMatrix[x][y] == FIRE) {
          nFires += 1;
        }
      }
    }  
  }
  return nFires;
}


