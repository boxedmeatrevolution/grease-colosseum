/* @pjs preload="/assets/large_fire.png, /assets/medium_fire.png, /assets/small_fire.png, /assets/hatguy_left.png, /assets/hatguy_right.png, /assets/gremlin_left.png, /assets/gremlin_right.png, /assets/ninja_left.png, /assets/ninja_right.png, /assets/robot_left.png, /assets/robot_right.png, /assets/skeleton_left.png, /assets/skeleton_right.png" */
class Entity {
  // Called when the entity is added to the game
  void create() {}
  // Called when the entity is removed from the game
  void destroy() {}
  // Called whenever the entity is to be rendered
  void render() {}
  // Called when the entity is to be updated
  void update(int phase, float delta) {}
  // The order in the render and update list of the entity
  int depth() {
    return 0;
  }
  boolean exists = false;
}

int firstUpdatePhase = 0;
int lastUpdatePhase = 0;

int STATE_LOADING = 0;
int STATE_IN_GAME = 1;
int STATE_GAME_OVER = 2;
int STATE_TITLE = 3;
int state = STATE_TITLE;

ArrayList<Entity> entities = new ArrayList<Entity>();
ArrayList<Entity> entitiesToBeAdded = new ArrayList<Entity>();
ArrayList<Entity> entitiesToBeRemoved = new ArrayList<Entity>();
ArrayList<Collider> colliders = new ArrayList<Collider>();

long score = 0;

boolean leftKeyPressed = false;
boolean rightKeyPressed = false;
boolean upKeyPressed = false;
boolean downKeyPressed = false;

boolean shootKeyPressed = false;
boolean secondaryShootKeyPressed = false;

float gameOverTimer = 0;
boolean isPlayerDead = false;

int levelIndex;

var lastUpdate = Date.now();
var timeDelta;

void addEntity(Entity entity) {
  entitiesToBeAdded.add(entity);
}

void removeEntity(Entity entity) {
  entitiesToBeRemoved.add(entity);
}

void sortEntities() {
  for (int i = 1; i < entities.size(); ++i) {
    Entity x = entities.get(i);
    int j = i;
    while (j > 0 && entities.get(j - 1).depth() < x.depth()) {
      entities.set(j, entities.get(j - 1));
      j -= 1;
    }
    entities.set(j, x);
  }
}

float standardizeAngle(float angle) {
  angle %= TAU;
  if (angle < 0) {
    angle += TAU;
  }
  return angle;
}

void gotoInGameState() {
  state = STATE_IN_GAME;
  lastUpdate = Date.now();
  gameOverTimer = 0;
  isPlayerDead = false;
  levelIndex = floor(random(levels.length));
  spawnLevel(levels[levelIndex]);
  
  Player player = new Player(width / 2, height / 2);
  GreaseSurface surface = new GreaseSurface();
  FireEffect fireEffect = new FireEffect();
  SpikeWall spikeWall = new SpikeWall();
  
  addEntity(player);
  addEntity(surface);
  addEntity(fireEffect);
  addEntity(spikeWall);
}

void gotoGameOverState() {
  state = STATE_GAME_OVER;
  levels[levelIndex].nSpawners = 0;
  entities.clear();
  entitiesToBeAdded.clear();
  entitiesToBeRemoved.clear();
  colliders.clear();
}

void gotoTitleState() {
  state = STATE_TITLE;
  levels[levelIndex].nSpawners = 0;
  entities.clear();
  entitiesToBeAdded.clear();
  entitiesToBeRemoved.clear();
  colliders.clear();
}

void setup () {
  size(800, 800);
  textureMode(IMAGE);
  levels = new Level[] {
    new Level1(), new Level2(), new Level3() };
}

void draw () {
  background(0, 0, 0);
  fill(255);
  if (state == STATE_TITLE) {
    text("GREASE WARS!!!!!!!", 64, 64);
    text("Press space to begin.", 64, 128);
    if (keyPressed && key == ' ') {
      gotoInGameState();
    }
  }
  else if (state == STATE_GAME_OVER) {
    text("Game over!", 64, 64);
    text("Your score was " + str(score) + ".", 64, 128);
    text("Press space to restart.", 64, 128 + 64);
    if (keyPressed && key == ' ') {
      gotoInGameState();
    } 
  }
  else if (state == STATE_IN_GAME) {
    text(frameRate, 32, 32);
    // Calculate the delta t
    var now = Date.now();
    timeDelta = (now - lastUpdate) / 1000.0f;
    lastUpdate = now;
    
    boolean isLevelOver = true;
    if (levels[levelIndex].nSpawners != 0) {
      isLevelOver = false;
      console.log("There be spawners! " + str(levels[levelIndex].nSpawners));
    }
    else {
      for (Entity entity : levels[levelIndex].enemies) {
        if (entity.exists) {
          isLevelOver = false;
          console.log("There be enemies!");
          break;
        }
      }
    }
    
    if (isLevelOver) {
      despawnLevel(levels[levelIndex]);
      int oldLevelIndex = levelIndex;
      while(levelIndex == oldLevelIndex) {
        levelIndex = floor(random(levels.length));
      }
      spawnLevel(levels[levelIndex]);
    }
    
    if (isPlayerDead) {
      gameOverTimer += timeDelta;
      if (gameOverTimer > 2.5) {
        gotoGameOverState();
      }
    }
    
    // Add entities in the add queue
    for (Entity entity : entitiesToBeAdded) {
      entities.add(entity);
      if (entity instanceof Collider) {
        colliders.add(entity);
      }
      entity.exists = true;
      entity.create();
    }
    // Remove entities in the remove queue
    for (Entity entity : entitiesToBeRemoved) {
      entities.remove(entity);
      if (entity instanceof Collider) {
        colliders.remove(entity);
      }
      entity.exists = false;
      entity.destroy();
    }
    entitiesToBeAdded.clear();
    entitiesToBeRemoved.clear();
    // Entities are sorted by depth
    sortEntities();
    for (int updatePhase = firstUpdatePhase; updatePhase <= lastUpdatePhase; ++updatePhase) {
      // Update every entity
      for (Entity entity : entities) {
        entity.update(updatePhase, timeDelta);
      }
      // Find and handle collisions
      if (updatePhase == 0) {
        for (int i = 0; i < colliders.size() - 1; ++i) {
          Collider first = colliders.get(i);
          for (int j = i + 1; j < colliders.size(); ++j) {
            Collider second = colliders.get(j);
            if (first.collides(second)) {
              first.onCollision(second, false);
              second.onCollision(first, true);
            }
          }
        }
      }
    }
    // Render every entity
    for (Entity entity : entities) {
      entity.render();
    }
  }
}

// Handle input
void keyPressed() {
  if (keyCode == UP || key == 'w') {
    upKeyPressed = true;
  }
  else if (keyCode == DOWN || key == 's') {
    downKeyPressed = true;
  }
  else if (keyCode == LEFT || key == 'a') {
    leftKeyPressed = true;
  }
  else if (keyCode == RIGHT || key == 'd') {
    rightKeyPressed = true;
  }
}

void keyReleased() {
  if (keyCode == UP || key == 'w') {
    upKeyPressed = false;
  }
  else if (keyCode == DOWN || key == 's') {
    downKeyPressed = false;
  }
  else if (keyCode == LEFT || key == 'a') {
    leftKeyPressed = false;
  }
  else if (keyCode == RIGHT || key == 'd') {
    rightKeyPressed = false;
  }
}

void mousePressed() {
  if (mouseButton == LEFT) {
    shootKeyPressed = true;
  }
  if (mouseButton == RIGHT) {
    secondaryShootKeyPressed = true;
  }
}

void mouseReleased() {
  if (mouseButton == LEFT) {
    shootKeyPressed = false;
  }
  if (mouseButton = RIGHT) {
    secondaryShootKeyPressed = false;
  }
}

void mouseOut() {
  shootKeyPressed = false;
  secondaryShootPressed = false;
}

