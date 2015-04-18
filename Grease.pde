class Grease extends Moving {
  
  Grease(float x_, float y_) {
    super(x_, y_, GREASE_FRICTION);
  }
  
  void create() {
    super.create();
  }
  void destroy() {
    super.destroy();
  }
  void render() {
    ellipse(x, y, 2 * radius, 2 * radius);
  }
  void update(int phase, float delta) {
    super.update(state, delta);
    if(state == MOVING_STATE) {
      if(!isMoving()) {
        state = GROUND_STATE;
        applyGreaseToMatrix(this);
      }
    } else {
      removeEntity(this);
    }
  }
  boolean isMoving() {
    // Is the grease still flying through the air?
    if(abs(velocityX) < 0.1 & abs(velocityY) < 0.1) {
        return false;
    }
    return true;
  }
  
  int state = 0;
  boolean isDead = false;
  float radius = 4;
  
  int MOVING_STATE = 0;
  int GROUND_STATE = 1;
  
  float GREASE_FRICTION = 500;
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
    for(int x = 0; x < greaseMatrix.length; x ++) {
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
    }
  }
  void update(int phase, float delta) {
    super.update(phase, delta);
    if(phase == 0) {
      updateGreaseMatrix(delta);
    }
  }
}

// Underlying grid representing the grease
byte[][] greaseMatrix;

// Dimensions of each grease grid cell
int CELL_WIDTH = 8;
int CELL_HEIGHT = 8;

byte NO_GREASE = 0;
byte GREASE = 1;
byte FIRE = 2;

float FLAMMABILITY = 0.3;
float EXTINGUISHABILITY = 0.1;

// Given the width and height of the game,
// create the underlying grid representing the grease
void initGreaseMatrix() {
  greaseMatrix = new byte[ceil(((float)width)/((float)CELL_WIDTH))][ceil(((float)height)/((float)CELL_HEIGHT))];
}

void updateGreaseMatrix(float delta) {
  for(int x = 0; x < greaseMatrix.length; x ++) {
    for(int y = 0; y < greaseMatrix[0].length; y ++) {
      if(greaseMatrix[x][y] == FIRE) {
        boolean hasGreaseNeighbour = false;
        if(x > 0 && y > 0 && greaseMatrix[x - 1][y - 1] == GREASE) {
          hasGreaseNeighbour = true;
          if(random(0, 1) > 1 - delta * FLAMMABILITY) {
            createFire(x - 1, y - 1);
          }
        }
        if(y > 0 && greaseMatrix[x][y - 1] == GREASE) {
          hasGreaseNeighbour = true;
          if(random(0, 1) > 1 - delta * FLAMMABILITY) {
            createFire(x, y - 1);
          }
        }
        if(x < greaseMatrix.length - 1 && y > 0 && greaseMatrix[x + 1][y - 1] == GREASE) {
          hasGreaseNeighbour = true;
          if(random(0, 1) > 1 - delta * FLAMMABILITY) {
            createFire(x + 1, y - 1);
          }
        }
        if(x > 0 && greaseMatrix[x - 1][y] == GREASE) {
          hasGreaseNeighbour = true;
          if(random(0, 1) > 1 - delta * FLAMMABILITY) {
            createFire(x - 1, y);
          }
        }
        if(x < greaseMatrix.length - 1 && greaseMatrix[x + 1][y] == GREASE) {
          hasGreaseNeighbour = true;
          if(random(0, 1) > 1 - delta * FLAMMABILITY) {
            createFire(x + 1, y);
          }
        }
        if(x > 0 && y < greaseMatrix[0].length - 1 && greaseMatrix[x - 1][y + 1] == GREASE) {
          hasGreaseNeighbour = true;
          if(random(0, 1) > 1 - delta * FLAMMABILITY) {
            createFire(x - 1, y + 1);
          }
        }
        if(y < greaseMatrix[0].length - 1 && greaseMatrix[x][y + 1] == GREASE) {
          hasGreaseNeighbour = true;
          if(random(0, 1) > 1 - delta * FLAMMABILITY) {
            createFire(x, y + 1);
          }
        }
        if(x < greaseMatrix.length - 1 && y < greaseMatrix[0].length - 1 && greaseMatrix[x + 1][y + 1] == GREASE) {
          hasGreaseNeighbour = true;
          if(random(0, 1) > 1 - delta * FLAMMABILITY) {
            createFire(x + 1, y + 1);
          }
        }
      }
    }
  }
}

// Set the cell at x,y in the matrix on fire and create particle effect
void createFire(int x, int y) {
  greaseMatrix[x][y] = FIRE;
  // TODO fire particles
}

// Add the grease to the grease matrix
void applyGreaseToMatrix(Grease grease) {
  int topLeftX = floor((grease.x - grease.radius) / CELL_WIDTH);
  int topLeftY = floor((grease.y - grease.radius) / CELL_HEIGHT);
  int botRightX = ceil((grease.x + grease.radius) / CELL_WIDTH);
  int botRightY = ceil((grease.y + grease.radius) / CELL_HEIGHT);
  for(int x = topLeftX; x <= botRightX; x ++) {
    for(int y = topLeftY; y <= botRightY; y ++) {
      greaseMatrix[x][y] = GREASE;
    }  
  }
}

// Returns true if the Collider has come into contact with grease
boolean touchingGrease(Collider entity) {
  int topLeftX = floor((entity.x - entity.radius) / CELL_WIDTH);
  int topLeftY = floor((entity.y - entity.radius) / CELL_HEIGHT);
  int botRightX = ceil((entity.x + entity.radius) / CELL_WIDTH);
  int botRightY = ceil((entity.y + entity.radius) / CELL_HEIGHT);
  for(int x = topLeftX; x <= botRightX; x ++) {
    for(int y = topLeftY; y <= botRightY; y ++) {
      if(greaseMatrix[x][y] == GREASE) {
        return true;  
      }
    }  
  }
  return false;
}


