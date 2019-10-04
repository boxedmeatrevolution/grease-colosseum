/* @pjs font="./assets/corbelb.ttf"; preload="./assets/large_fire.png, ./assets/medium_fire.png, ./assets/small_fire.png, ./assets/hatguy_left.png, ./assets/hatguy_right.png, ./assets/gremlin_left.png, ./assets/gremlin_right.png, ./assets/ninja_left.png, ./assets/ninja_right.png, ./assets/robot_left.png, ./assets/robot_right.png, ./assets/skeleton_left.png, ./assets/skeleton_right.png, ./assets/dwarf_left.png, ./assets/dwarf_right.png, ./assets/barrel.png, ./assets/flaming_barrel.png, ./assets/bomb.png, ./assets/ninja_star.png, ./assets/pillar.png, ./assets/flame_shooter.png, ./assets/grease_particle.png, ./assets/soot.png, ./assets/background.png, ./assets/blood_particle.png, ./assets/death.png, ./assets/player_dash.png, ./assets/enemy_dash.png, ./assets/heart.png, ./assets/explosion.png, ./assets/portalLoop.png, ./assets/portalStart.png, ./assets/outline.png, ./assets/TitleScreen.png, ./assets/GameOver.png"; */

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
int state = STATE_LOADING;

ArrayList<Entity> entities = new ArrayList<Entity>();
ArrayList<Entity> entitiesToBeAdded = new ArrayList<Entity>();
ArrayList<Entity> entitiesToBeRemoved = new ArrayList<Entity>();
ArrayList<Collider> colliders = new ArrayList<Collider>();

long score = 0;
long levelPointsValue;

boolean leftKeyPressed = false;
boolean rightKeyPressed = false;
boolean upKeyPressed = false;
boolean downKeyPressed = false;

boolean shootKeyPressed = false;
boolean secondaryShootKeyPressed = false;

float gameOverTimer = 0;
boolean isPlayerDead = false;

int levelIndex;

PGraphics groundImage;
PFont scoreFont;

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

float angleBetween(float angle1, float angle2) {
  float result = standardizeAngle(angle1 - angle2);
  if (result > PI) {
    result -= TAU;
  }
  return result;
}

void gotoInGameState() {
  sounds["fire"].volume = 0;
  sounds["fire"].loop = true;
  sounds["fire"].play();
  
  state = STATE_IN_GAME;
  levelPointsValue = 4;
  score = 0;
  lastUpdate = Date.now();
  gameOverTimer = 0;
  isPlayerDead = false;
  levelIndex = 0;//floor(random(levels.length));
  spawnLevel(levels[levelIndex], levelPointsValue);
  
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
  sounds["fire"].pause();
  
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
    new Level1(), new Level2(), new Level3(), new Level4(), new Level5(), new Level6(), new Level7() };
  groundImage = loadImage("./assets/background.png");
  loadAudio("musicFirstTime", "./assets/ld32greaseArenaFirstTime.ogg");
  loadAudio("musicLoop", "./assets/ld32greaseArenaLoop.ogg");
  loadAudio("collision", "./assets/sounds/collision.wav");
  loadAudio("dwarfShoot", "./assets/sounds/dwarf_shoot.wav");
  loadAudio("enemyHurt", "./assets/sounds/enemy_hurt.wav");
  loadAudio("enemyDash", "./assets/sounds/enemy_dash.wav");
  loadAudio("enemyDeath", "./assets/sounds/enemy_death.wav");
  loadAudio("explosion", "./assets/sounds/explosion.wav");
  loadAudio("footstep", "./assets/sounds/footstep.wav");
  loadAudio("ninjaShoot", "./assets/sounds/ninja_shoot.wav");
  loadAudio("playerDash", "./assets/sounds/player_dash.wav");
  loadAudio("playerDeath", "./assets/sounds/player_death.wav");
  loadAudio("prepareSpawn", "./assets/sounds/prepare_spawn.wav");
  loadAudio("robotShoot", "./assets/sounds/robot_shoot.wav");
  loadAudio("spawn", "./assets/sounds/spawn.wav");
  loadAudio("fire", "./assets/sounds/veryLoudFireLoop.ogg");
  loadAudio("bombTick", "./assets/sounds/bombTick.wav");
  sounds["musicFirstTime"].addEventListener("ended", startLoop, false); // It works!!
  sounds["musicLoop"].loop = true;
  sounds["musicFirstTime"].play();
  scoreFont = createFont("./assets/corbelb.ttf", 32);
}

function startLoop() {
  sounds["musicLoop"].play();
}

PImage outline = loadImage("./assets/outline.png");
PImage titleScreen = loadImage("./assets/TitleScreen.png");
PImage gameOver = loadImage("./assets/GameOver.png");

void draw () {
  background(0, 0, 0);
  fill(255);
  if (state == STATE_LOADING) {
    text("Loading", 64, 64);
    if (audioFilesLoaded == nAudioFiles) {
      gotoTitleState();
    }
  }
  if (state == STATE_TITLE) {
    image(titleScreen, 0, 0);
    image(outline, 0, 0);
    if (keyPressed && key == ' ') {
      gotoInGameState();
    }
  }
  else if (state == STATE_GAME_OVER) {
    image(gameOver, 0, 0);
    image(outline, 0, 0);
    textFont(scoreFont);
    text("Your score was " + str(score) + ".", 310, 475);
    text("Press space to restart.", 290, 590);
    if (keyPressed && key == ' ') {
      gotoInGameState();
    } 
  }
  else if (state == STATE_IN_GAME) {
    // Calculate the delta t
    var now = Date.now();
    timeDelta = (now - lastUpdate) / 1000.0f;
    lastUpdate = now;
    
    image(groundImage, 0, 0);
    
    boolean isLevelOver = true;
    if (levels[levelIndex].nSpawners != 0) {
      isLevelOver = false;
    }
    else {
      for (Entity entity : levels[levelIndex].enemies) {
        if (entity.exists) {
          isLevelOver = false;
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
      spawnLevel(levels[levelIndex], levelPointsValue);
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
    fill(200, 50, 50);
    textFont(scoreFont);
    text(str(score), 64, 64);
  }
}

// Handle input
void keyPressed() {
  if (keyCode == UP || key == 'w' || key == 'W' || key == 'z' || key == 'Z') {
    upKeyPressed = true;
  }
  else if (keyCode == DOWN || key == 's' || key == 'S') {
    downKeyPressed = true;
  }
  else if (keyCode == LEFT || key == 'a' || key == 'A' || key == 'q' || key == 'Q') {
    leftKeyPressed = true;
  }
  else if (keyCode == RIGHT || key == 'd' || key == 'D') {
    rightKeyPressed = true;
  }
}

void keyReleased() {
  if (keyCode == UP || key == 'w' || key == 'W' || key == 'z' || key == 'Z') {
    upKeyPressed = false;
  }
  else if (keyCode == DOWN || key == 's' || key == 'S') {
    downKeyPressed = false;
  }
  else if (keyCode == LEFT || key == 'a' || key == 'A' || key == 'q' || key == 'Q') {
    leftKeyPressed = false;
  }
  else if (keyCode == RIGHT || key == 'd' || key == 'D') {
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
    if (secondaryShootKeyPressed) {
      secondaryShootKeyPressed = false;
    }
    else {
      shootKeyPressed = false;
    }
  }
}

void mouseOut() {
  shootKeyPressed = false;
  secondaryShootPressed = false;
}

