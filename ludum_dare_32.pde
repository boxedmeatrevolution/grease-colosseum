/* @pjs font="/LudumDare32/assets/corbelb.ttf"; preload="/LudumDare32/assets/large_fire.png, /LudumDare32/assets/medium_fire.png, /LudumDare32/assets/small_fire.png, /LudumDare32/assets/hatguy_left.png, /LudumDare32/assets/hatguy_right.png, /LudumDare32/assets/gremlin_left.png, /LudumDare32/assets/gremlin_right.png, /LudumDare32/assets/ninja_left.png, /LudumDare32/assets/ninja_right.png, /LudumDare32/assets/robot_left.png, /LudumDare32/assets/robot_right.png, /LudumDare32/assets/skeleton_left.png, /LudumDare32/assets/skeleton_right.png, /LudumDare32/assets/dwarf_left.png, /LudumDare32/assets/dwarf_right.png, /LudumDare32/assets/barrel.png, /LudumDare32/assets/flaming_barrel.png, /LudumDare32/assets/bomb.png, /LudumDare32/assets/ninja_star.png, /LudumDare32/assets/pillar.png, /LudumDare32/assets/flame_shooter.png, /LudumDare32/assets/grease_particle.png, /LudumDare32/assets/soot.png, /LudumDare32/assets/background.png, /LudumDare32/assets/blood_particle.png, /LudumDare32/assets/death.png, /LudumDare32/assets/player_dash.png, /LudumDare32/assets/enemy_dash.png, /LudumDare32/assets/heart.png, /LudumDare32/assets/explosion.png, /LudumDare32/assets/portalLoop.png, /LudumDare32/assets/portalStart.png, /LudumDare32/assets/outline.png, /LudumDare32/assets/TitleScreen.png, /LudumDare32/assets/GameOver.png"; */

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
  groundImage = loadImage("/LudumDare32/assets/background.png");
  loadAudio("musicFirstTime", "/LudumDare32/assets/ld32greaseArenaFirstTime.ogg");
  loadAudio("musicLoop", "/LudumDare32/assets/ld32greaseArenaLoop.ogg");
  loadAudio("collision", "/LudumDare32/assets/sounds/collision.wav");
  loadAudio("dwarfShoot", "/LudumDare32/assets/sounds/dwarf_shoot.wav");
  loadAudio("enemyHurt", "/LudumDare32/assets/sounds/enemy_hurt.wav");
  loadAudio("enemyDash", "/LudumDare32/assets/sounds/enemy_dash.wav");
  loadAudio("enemyDeath", "/LudumDare32/assets/sounds/enemy_death.wav");
  loadAudio("explosion", "/LudumDare32/assets/sounds/explosion.wav");
  loadAudio("footstep", "/LudumDare32/assets/sounds/footstep.wav");
  loadAudio("ninjaShoot", "/LudumDare32/assets/sounds/ninja_shoot.wav");
  loadAudio("playerDash", "/LudumDare32/assets/sounds/player_dash.wav");
  loadAudio("playerDeath", "/LudumDare32/assets/sounds/player_death.wav");
  loadAudio("prepareSpawn", "/LudumDare32/assets/sounds/prepare_spawn.wav");
  loadAudio("robotShoot", "/LudumDare32/assets/sounds/robot_shoot.wav");
  loadAudio("spawn", "/LudumDare32/assets/sounds/spawn.wav");
  loadAudio("fire", "/LudumDare32/assets/sounds/veryLoudFireLoop.ogg");
  loadAudio("bombTick", "/LudumDare32/assets/sounds/bombTick.wav");
  sounds["musicFirstTime"].addEventListener("ended", startLoop, false); // It works!!
  sounds["musicLoop"].loop = true;
  sounds["musicFirstTime"].play();
  scoreFont = createFont("/LudumDare32/assets/corbelb.ttf", 32);
}

function startLoop() {
  sounds["musicLoop"].play();
}

PImage outline = loadImage("/LudumDare32/assets/outline.png");
PImage titleScreen = loadImage("/LudumDare32/assets/TitleScreen.png");
PImage gameOver = loadImage("/LudumDare32/assets/GameOver.png");

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

// How to load an audio file:
//
//  loadAudio("gameMusic1", "LudumDare32/assets/music1.ogg");
//
// When the audio file is loaded, 'audioFilesLoaded' is incremented by 1
//
//  if(audioFilesLoaded == 1) {
//    text("One audio file is loaded!");
//  }
//
// How to play the loaded audio file:
//
//  playSound("gameMusic1");
//
// Powered by javascript!
//

// Number of audio files loaded
var audioFilesLoaded = 0;
var nAudioFiles = 0;

// A map of all the audio files that have been loaded
var sounds = new Object();

// Play an audio file from the key 'name'
function playSound(var name)
{
    sounds[name].play();
}

// Load an audio file
// 'name' is the key to retrieve the audio object from 'sounds'
// 'uri' is the path to the file
function loadAudio(var name, var uri)
{
    var audio = new Audio();
    sounds[name] = audio;
    audio.addEventListener("canplaythrough", audioFileLoaded, false); // It works!!
    audio.src = uri;
    nAudioFiles++;
    return audio;
}

// This function will be called when an audio file is loaded
function audioFileLoaded()
{
    audioFilesLoaded++;
}
class Barrel extends PhysicsCollider {
  
  Barrel(float x_, float y_) {
    super(x_, y_, 1, 16, 500);
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
    if (other instanceof Harmful || other instanceof ContinuousHarmful) {
      explode();
    }
  }
  
  void create() {
    super.create();
    if (barrelSheet == null) {
      barrelSheet = loadSpriteSheet("/LudumDare32/assets/barrel.png", 1, 1, 32, 32);
      flamingBarrelSheet = loadSpriteSheet("/LudumDare32/assets/flaming_barrel.png", 3, 1, 32, 32);
    }
    barrelAnimation = new Animation(barrelSheet, 1, 0);
    flamingBarrelAnimation = new Animation(flamingBarrelSheet, 0.2, 0, 1, 2);
  }
  
  void destroy() {
    super.destroy();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      barrelAnimation.update(delta);
      flamingBarrelAnimation.update(delta);
      if (triggered) {
        timer += delta;
        if (timer > 1.5) {
          addEntity(new Explosion(x, y));
          for (int i = 0; i < 5; ++i) {
            Flame particle = new Flame(x, y);
            float velocity = random(0, 400);
            float angle = random(0, TAU);
            particle.velocityX = velocity * cos(angle);
            particle.velocityY = -velocity * sin(angle);
            addEntity(particle);
          }
          removeEntity(this);
        }
      }
      if (touchingFire(x, y, radius)) {
        explode();
      }
    }
  }
  
  void render() {
    super.render();
    if (triggered) {
      flamingBarrelAnimation.drawAnimation(x - 16, y - 16, 32, 32);
    }
    else {
      barrelAnimation.drawAnimation(x - 16, y - 16, 32, 32);
    }
  }
  
  int depth() {
    return -70;
  }
  
  void explode () {
    triggered = true;
  }
  
  float timer = 0;
  boolean triggered = false;
  
  Animation barrelAnimation;
  Animation flamingBarrelAnimation;
  
}

SpriteSheet barrelSheet;
SpriteSheet flamingBarrelSheet;

class BasicEnemy extends EnemyEntity{
  BasicEnemy(float x_, float y_, float facingDirection_) {
    super(x_, y_, _MASS, _RADIUS, _FRICTION, _VALUE, _HP, facingDirection_, _ACCELERATION, _MAXVELOCITY, _GREASE_ACCELERATION, _TURN_SPEED);
  }
  
  void onCollision(Collider cOther, boolean wasHandled) {
    super.onCollision(cOther, wasHandled);
  }
  
  void create() {
    super.create();
    if (gremlinLeftSheet == null) {
      gremlinLeftSheet = loadSpriteSheet("/LudumDare32/assets/gremlin_left.png", 5, 1, 32, 32);
      gremlinRightSheet = loadSpriteSheet("/LudumDare32/assets/gremlin_right.png", 5, 1, 32, 32);
      enemyDashImage = loadImage("/LudumDare32/assets/enemy_dash.png");
    }
    gremlinLeftAnimation = new Animation(gremlinLeftSheet, 0.1, 1, 2, 3, 4);
    gremlinRightAnimation = new Animation(gremlinRightSheet, 0.1, 1, 2, 3, 4);
  }
  
  void destroy() {
    super.destroy();
  }
  
  void render() {
    super.render();
    facingDirection = standardizeAngle(facingDirection);
    if (facingDirection < HALF_PI || facingDirection > 3 * HALF_PI) {
      gremlinRightAnimation.drawAnimation(x - 16, y - 16, 32, 32);
    }
    else {
      gremlinLeftAnimation.drawAnimation(x - 16, y - 16, 32, 32);
    }
    if (reallyIsDashing) {
      translate(x, y);
      float angle = atan2(velocityY, velocityX);
      rotate(angle);
      image(enemyDashImage, -24, -24);
      rotate(-angle);
      translate(-x, -y);
    }
  }
  
  float walkTowardsPlayer(float delta) {
    return super.walkTowardsPlayer(delta);
  }
  
  float turnTowardsPlayer(float delta) {
    return super.turnTowardsPlayer(delta);
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      gremlinLeftAnimation.time = 10 / sqrt(sq(velocityX) + sq(velocityY));
      gremlinRightAnimation.time = gremlinLeftAnimation.time;
      gremlinLeftAnimation.update(delta);
      gremlinRightAnimation.update(delta);
      dist = walkTowardsPlayer(delta);
      angle = turnTowardsPlayer(delta);
      
      if (reallyIsDashing && abs(velocityX) < _MAXVELOCITY * 4 && abs(velocityY) < _MAXVELOCITY * 4) {
        reallyIsDashing = false;
      }
      
      if (canDash) {
        if ((dist < _MAX_DIST_TO_DASH) && (angle < _MAX_ANGLE_TO_DASH)) {
          isDashing = true;
          chargeTimer = 0;
          canDash = false;
          dashTimer = 0;
          addEntity(new ChargeBox(this, _CHARGE_TIME));
        }
      }
      else if (isDashing) {
        if (chargeTimer > _CHARGE_TIME) {
          velocityX += cos(facingDirection) * _DASH_FORCE;
          velocityY -= sin(facingDirection) * _DASH_FORCE;
          reallyIsDashing = true;
          sounds["enemyDash"].play();
          isDashing = false;
        }
        else {
          chargeTimer += delta;
        }
      }
      else {
        dashTimer += delta;
        if (dashTimer > _DASH_RELOAD) {
          canDash = true;
        }
      }
    }
  }

  //Basic Enemy properties
  float _MASS = 1;
  float _RADIUS = 16;
  int _VALUE = 1;
  float _HP = 10;
  float _ACCELERATION = 1200;
  float _GREASE_ACCELERATION = 200;
  float _FRICTION = 600;
  float _MAXVELOCITY = 50;
  float _TURN_SPEED = HALF_PI;
  
  float _MAX_DIST_TO_DASH = 100;
  float _MAX_ANGLE_TO_DASH = PI/4;
  float _DASH_FORCE = 400;
  float _DASH_RELOAD = 2;
  float _CHARGE_TIME = 1;
  float dashTimer = 0;
  float chargeTimer = 0;
  boolean isDashing = false;
  boolean reallyIsDashing = false;
  boolean canDash = true;
  
  Animation gremlinLeftAnimation;
  Animation gremlinRightAnimation;
}

SpriteSheet gremlinLeftSheet;
SpriteSheet gremlinRightSheet;

PImage enemyDashImage;
class BigBasicEnemy extends EnemyEntity{
  BigBasicEnemy(float x_, float y_, float facingDirection_) {
    super(x_, y_, _MASS, _RADIUS, _FRICTION, _VALUE, _HP, facingDirection_, _ACCELERATION, _MAXVELOCITY, _GREASE_ACCELERATION, _TURN_SPEED);
  }
  
  void onCollision(Collider cOther, boolean wasHandled) {
    super.onCollision(cOther, wasHandled);
  }
  
  void create() {
    super.create();
    if (skeletonLeftSheet == null) {
      skeletonLeftSheet = loadSpriteSheet("/LudumDare32/assets/skeleton_left.png", 5, 1, 32, 32);
      skeletonRightSheet = loadSpriteSheet("/LudumDare32/assets/skeleton_right.png", 5, 1, 32, 32);
      enemyDashImage = loadImage("/LudumDare32/assets/enemy_dash.png");
    }
    skeletonLeftAnimation = new Animation(skeletonLeftSheet, 0.2, 1, 2, 3, 4);
    skeletonRightAnimation = new Animation(skeletonRightSheet, 0.2, 1, 2, 3, 4);
  }
  
  void destroy() {
    super.destroy();
  }
  
  void render() {
    super.render();
    facingDirection = standardizeAngle(facingDirection);
    if (facingDirection < HALF_PI || facingDirection > 3 * HALF_PI) {
      skeletonRightAnimation.drawAnimation(x - 32, y - 32, 64, 64);
    }
    else {
      skeletonLeftAnimation.drawAnimation(x - 32, y - 32, 64, 64);
    }
    if (reallyIsDashing) {
      translate(x, y);
      float angle = atan2(velocityY, velocityX);
      rotate(angle);
      image(enemyDashImage, -24, -24);
      rotate(-angle);
      translate(-x, -y);
    }
  }
  
  float walkTowardsPlayer(float delta) {
    return super.walkTowardsPlayer(delta);
  }
  
  float turnTowardsPlayer(float delta) {
    return super.turnTowardsPlayer(delta);
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      skeletonLeftAnimation.time = 10 / sqrt(sq(velocityX) + sq(velocityY));
      skeletonRightAnimation.time = skeletonLeftAnimation.time;
      skeletonLeftAnimation.update(delta);
      skeletonRightAnimation.update(delta);
      
      dist = walkTowardsPlayer(delta);
      angle = turnTowardsPlayer(delta);
      
      if (reallyIsDashing && abs(velocityX) < _MAXVELOCITY * 4 && abs(velocityY) < _MAXVELOCITY * 4) {
        reallyIsDashing = false;
      }
      
      if (canDash) {
        if ((dist < _MAX_DIST_TO_DASH) && (angle < _MAX_ANGLE_TO_DASH)) {
          isDashing = true;
          chargeTimer = 0;
          canDash = false;
          dashTimer = 0;
          addEntity(new ChargeBox(this, _CHARGE_TIME));
        }
      }
      else if (isDashing) {
        if (chargeTimer > _CHARGE_TIME) {
          velocityX += cos(facingDirection) * _DASH_FORCE;
          velocityY -= sin(facingDirection) * _DASH_FORCE;
          sounds["enemyDash"].play();
          flameTimer = _FLAME_TIME;
          isDashing = false; 
          reallyIsDashing = true;
        }
        else {
          chargeTimer += delta;
        }
      }
      else {
        dashTimer += delta;
        if (dashTimer > _DASH_RELOAD) {
          canDash = true;
        }
      }
      if (flameTimer > 0) {
        Flame f = new Flame(x, y);
        float angle = atan2(-velocityY, velocityY);
        angle = random(angle - PI/10, angle + PI/10);
        f.velocityX = _FLAME_SPEED*cos(angle);
        f.velocityY = _FLAME_SPEED*sin(angle);
        addEntity(f);
        flameTimer -= delta;
      }
    }
  }

  //Basic Enemy properties
  float _MASS = 2;
  float _RADIUS = 32;
  int _VALUE = 4;
  float _HP = 20;
  float _ACCELERATION = 1000;
  float _GREASE_ACCELERATION = 100;
  float _FRICTION = 600;
  float _MAXVELOCITY = 50;
  float _TURN_SPEED = 0.5;
  
  float _MAX_DIST_TO_DASH = 200;
  float _MAX_ANGLE_TO_DASH = PI/4;
  float _DASH_FORCE = 500;
  float _DASH_RELOAD = 3;
  float _CHARGE_TIME = 1;
  float _FLAME_TIME = 0.66; // 2/3 of a second;
  float _FLAME_SPEED = 75;
  float dashTimer = 0;
  boolean canDash = true;
  float chargeTimer = 0;
  boolean isDashing = false;
  boolean canDash = true;
  float flameTimer = 0;
  boolean reallyIsDashing = false;
  
  Animation skeletonLeftAnimation;
  Animation skeletonRightAnimation;
}

SpriteSheet skeletonLeftSheet;
SpriteSheet skeletonRightSheet;

class Blood extends Moving {
  
  Blood(float x_, float y_) {
    super(x_, y_, GREASE_FRICTION);
  }
  
  float radius = 8;
  
  void create() {
    super.create();
    if (bloodImage == null) {
      bloodImage = loadImage("/LudumDare32/assets/blood_particle.png");
    }
  }
  void destroy() {
    super.destroy();
  }
  void render() {
    super.render();
    if (radius > 2) {
      greaseGraphics.beginDraw();
      greaseGraphics.image(bloodImage, x - radius, y - radius, 2 * radius, 2 * radius);
      greaseGraphics.endDraw();
    }
    //image(bloodImage, x - 4, y - 4, 8, 8);
  }
  void update(int phase, float delta) {
    super.update(state, delta);
    if (phase == 0) {
      radius -= 16 * delta;
      if (radius < 0) {
        radius = 0;
      }
      if(state == MOVING_STATE) {
        if(!isMoving()) {
          state = GROUND_STATE;
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
  
  int MOVING_STATE = 0;
  int GROUND_STATE = 1;
  
  float GREASE_FRICTION = 500;
}

PImage bloodImage;

class Bomb extends PhysicsCollider {
  Bomb(float x_, float y_) {
    super(x_, y_, 1, 8, 500);
  }
  
  void create() {
    super.create();
    if (bombSheet == null) {
      bombSheet = loadSpriteSheet("/LudumDare32/assets/bomb.png", 3, 1, 16, 16);
    }
    bombAnimation = new Animation(bombSheet, 0.2, 0, 1, 2);
  }
  
  void destroy() {
    super.destroy();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      bombAnimation.update(delta);
      timer += delta;
      tickTimer -= delta;
      if (tickTimer < 0) {
        tickTimer = 0.75;
        sounds["bombTick"].play();
      }
      if (timer > 3) {
        addEntity(new Explosion(x, y));
        for (int i = 0; i < 5; ++i) {
          Flame particle = new Flame(x, y);
          float velocity = random(0, 400);
          float angle = random(0, TAU);
          particle.velocityX = velocity * cos(angle);
          particle.velocityY = -velocity * sin(angle);
          addEntity(particle);
        }
        removeEntity(this);
      }
    }
  }
  
  void render() {
    super.render();
    bombAnimation.drawAnimation(x - radius, y - radius, 16, 16);
  }
  
  int depth() {
    return -70;
  }
  
  float timer = 0;
  float tickTimer = 0.75;
  
  Animation bombAnimation;
  
}

SpriteSheet bombSheet;

class BomberEnemy extends EnemyEntity {
  
  BomberEnemy(float x_, float y_, float facingDirection_) {
    super(x_, y_, _MASS, _RADIUS, _FRICTION, _VALUE, _HP, facingDirection_, _ACCELERATION, _MAXVELOCITY, _GREASE_ACCELERATION, _TURN_SPEED);
  }
  
  void onCollision(Collider cOther, boolean wasHandled) {
    super.onCollision(cOther, wasHandled);
  }
  
  void create() {
    super.create();
    if (dwarfLeftSheet == null) {
      dwarfLeftSheet = loadSpriteSheet("/LudumDare32/assets/dwarf_left.png", 5, 1, 32, 32);
      dwarfRightSheet = loadSpriteSheet("/LudumDare32/assets/dwarf_right.png", 5, 1, 32, 32);
    }
    dwarfLeftAnimation = new Animation(dwarfLeftSheet, 0.2, 1, 2, 3, 4);
    dwarfRightAnimation = new Animation(dwarfRightSheet, 0.2, 1, 2, 3, 4);
  }
  
  void destroy() {
    super.destroy();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      dwarfLeftAnimation.time = 10 / sqrt(sq(velocityX) + sq(velocityY));
      dwarfRightAnimation.time = dwarfLeftAnimation.time;
      dwarfLeftAnimation.update(delta);
      dwarfRightAnimation.update(delta);
      walkTowardsPlayer(delta);
      turnTowardsPlayer(delta);
      if (isCharging) {
        chargeTime += delta;
        if (chargeTime > MAX_CHARGE_TIME) {
          isCharging = false;
          Bomb bomb = new Bomb(x + radius * cos(facingDirection), y - radius * sin(facingDirection));
          addEntity(bomb);
          timeUntilNextBomb = random(3.0f, 4.0f);
          sounds["dwarfShoot"].play();
        }
      }
      else if (timeUntilNextBomb < 0.0f) {
        isCharging = true;
        chargeTime = 0;
        addEntity(new ChargeBox(this, MAX_CHARGE_TIME));
      }
      else {
        timeUntilNextBomb -= delta;
      }
    }
  }
  
  void render() {
    super.render();
    facingDirection = standardizeAngle(facingDirection);
    if (facingDirection < HALF_PI || facingDirection > 3 * HALF_PI) {
      dwarfRightAnimation.drawAnimation(x - 16, y - 16, 32, 32);
    }
    else {
      dwarfLeftAnimation.drawAnimation(x - 16, y - 16, 32, 32);
    }
  }
  
  //Basic Enemy properties
  float _MASS = 1;
  float _RADIUS = 16;
  int _VALUE = 7;
  float _HP = 1;
  float _ACCELERATION = 1200;
  float _GREASE_ACCELERATION = 200;
  float _FRICTION = 600;
  float _MAXVELOCITY = 50;
  float _TURN_SPEED = HALF_PI;
  
  float MAX_CHARGE_TIME = 2;
  float chargeTime = 0;
  boolean isCharging = false;
  float timeUntilNextBomb = random(2.0f, 3.0f);
  
  Animation dwarfLeftAnimation;
  Animation dwarfRightAnimation;
  
}

SpriteSheet dwarfLeftSheet;
SpriteSheet dwarfRightSheet;

// A class for the bullets Shooting Enemies Shoot. 
class Bullet extends Entity {
  float x, y;
  float dx, dy;
  
  Bullet (float _x, float _y, float _dx, float _dy) {
    x = _x;
    y = _y;
    dx = _dx;
    dy = _dy;
    
  }
  
  void create () {
    super.create();
    if (ninjaStarSheet == null) {
      ninjaStarSheet = loadSpriteSheet("/LudumDare32/assets/ninja_star.png", 4, 1, 24, 24);
    }
    ninjaStarAnimation = new Animation(ninjaStarSheet, 0.2, 0, 1, 2, 3);
  }
  
  void destroy () {
    super.destroy();
  }
  
  void update (int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      ninjaStarAnimation.update(delta);
      x += dx * delta;
      y += dy * delta;
      
      //If bullet has left the screen
      if (x < 0 || y < 0 || x > width || y > height) {
        removeEntity(this);
      } else {
        for (Collider cl : colliders) {
          if (cl != null && colliding(cl)) collided(cl);
        }
      }
    }
  }
  
  //Test if cl is hit by bullet
  boolean colliding (Collider cl) {
    /*float px = cl.x;
    float py = cl.y;
    float pr = cl.radius;
    
    float vx = px - x;
    float vy = py - y;
    
    vx -= dx*((dx*vx + dy*vy) / (sq(dx) + sq(dy)));
    vy -= dy*((dx*vx + dy*vy) / (sq(dx) + sq(dy)));
    
    return iDist(0,0, vx, vy) <= pr && iDist(x,y, px - vx, py - vx) <= iDist(0,0, dx, dy);*/
    return iDist(x, y, cl.x, cl.y) <= cl.radius + 8;
  }
  
  //Is run when cl is hit by the bullet!!
  void collided (Collider cl) {
    if (cl instanceof Player) ((Player) cl).hurt();
    if (cl instanceof Barrel) ((Barrel) cl).explode();
    //removeEntity(this);
  }
  
  void render () {
    super.render();
    ninjaStarAnimation.drawAnimation(x - 12, y - 12, 24, 24);
  }
  
  int depth() {
    return -80;
  }
  
  Animation ninjaStarAnimation;
  
}

float iDist (float x, float y, float a, float b) {
  return sqrt(sq(x-a) + sq(y - b));
}

SpriteSheet ninjaStarSheet;
class ChargeBox extends Moving {
  ChargeBox(Entity entity_, float chargeTime_){
    super(entity_.x, entity_.y, 0);
    entity = entity_;
    stayTime = chargeTime_;
  }
  
  void create() {
    super.create();
  }
  
  void destroy() {
    super.destroy();
  }
  
  void render() {
    super.render();
    if (entity.exists) {
      fill(255, 255, 50, alpha);
      noStroke();
      rect(entity.x - entity.radius, 
           entity.y - entity.radius,
           entity.radius * 2, entity.radius * 2
      );
    } 
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      alpha = 100 * sin((2 * PI / 0.5) * (timer)) + 100;
      if (timer > stayTime) {
        removeEntity(this); 
      }
    }
    timer += delta;
  }
  
  int depth() {
    return -110;
  }
  
  int alpha = 255;
  int timer = 0;
  float stayTime = 1;
  Entity entity;
}
class Collider extends Moving {
  
  Collider(float x_, float y_, float radius_, float friction_) {
    super(x_, y_, friction_);
    radius = radius_;
  }
  
  void onCollision(Collider other, boolean wasHandled) {}
  
  void create() {
    super.create();
  }
  
  void destroy() {
    super.destroy();
  }
  
  void render() {
    super.render();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
  }
  
  int depth() {
    return 0;
  }
  
  boolean collides(Collider other) {
    float deltaX = x - other.x;
    float deltaY = y - other.y;
    float distanceSqr = deltaX * deltaX + deltaY * deltaY;
    float totalRadius = radius + other.radius;
    return distanceSqr <= totalRadius * totalRadius;
  }
  
  boolean intersects(float pointX, float pointY) {
    float deltaX = pointX - x;
    float deltaY = pointY - y;
    float distanceSqr = deltaX * deltaX + deltaY * deltaY;
    return distanceSqr <= radius * radius;
  }
  
  float radius;
}

class ContinuousHarmful extends Collider{
  ContinuousHarmful(float x_, float y_, float radius_, float friction_, float damage_) {
    super(x_, y_, radius_, friction_);
    damage = damage_;
  }
  
  void onCollision(Collider cOther, boolean wasHandled) {
    super.onCollision(cOther, wasHandled);
  }
  
  void create() {
    super.create();
  }
  
  void destroy() {
    super.destroy();
  }
  
  void render() {
    super.render();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
  }
  
  float damage;
  
}
class DeadBody extends Moving {
  
  DeadBody(float x_, float y_, float velocityX_, float velocityY_, float radius_) {
    super(x_, y_, 1000);
    velocityX = velocityX_;
    velocityY = velocityY_;
    radius = radius_;
  }
  
  void create() {
    super.create();
    if (deathSheet == null) {
      deathSheet = loadSpriteSheet("/LudumDare32/assets/death.png", 10, 1, 32, 64);
    }
    deathAnimation = new Animation(deathSheet, 0.1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9);
  }
  
  void destroy() {
    super.destroy();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    deathAnimation.update(delta);
  }
  
  void render() {
    super.render();
    deathAnimation.drawAnimation(x - 16, y - 16 - 32, 32, 64);
  }
  
  int depth() {
    return -10;
  }
  
  float radius;
  Animation deathAnimation;
  
}

SpriteSheet deathSheet;

class EnemyEntity extends PhysicsCollider{
  EnemyEntity(float x_, float y_, float mass_, float radius_, float friction_, 
              int value_, float hp_, float facingDirection_, float acceleration_,
              float maxVelocity_, float greaseAcceleration_, float turnSpeed_) {
    super(x_, y_, mass_, radius_, friction_);
    value = value_;
    hp = hp_;
    lastHp = hp_;
    facingDirection = facingDirection_;
    acceleration = acceleration_;
    maxVelocity = maxVelocity_;
    groundFriction = friction_;
    greaseAcceleration = greaseAcceleration_;
    turnSpeed = turnSpeed_;
  }
  
  void onCollision(Collider cOther, boolean wasHandled) {
    super.onCollision(cOther, wasHandled);
    if (cOther instanceof Harmful) {
      hurt(((Harmful) cOther).damage);
    }
    if (cOther instanceof ContinuousHarmful) {
      hurt(((ContinuousHarmful) cOther).damage * timeDelta);
    }
  }
  
  void create() {
    super.create();
  }
  
  void destroy() {
    super.destroy();
  }
  
  void render() {
    super.render();
  }
  
  void hitEdge() {
    super.hitEdge();
    sounds["enemyHurt"].play();
    hurt(5);
  }
  
  float turnTowardsPlayer(float delta) {
    last_refresh += delta;
    float angle = TAU;
    //update player
    if (last_refresh > _ENTITY_REFRESH_TIME) {
      player = null;
      for (Entity entity : entities) {
        if (entity instanceof Player) {
          player = entity;
          break;
        }
      }
    }
    if (player != null) {
      float playerDirection = atan2(-(player.y - y), player.x - x);
      facingDirection = facingDirection % TAU;
      boolean pBigger = false;
      if (playerDirection > facingDirection) {
        pBigger = true;
      }
      if (((pBigger) && (playerDirection - facingDirection < PI)) ||
      ((!pBigger) && (facingDirection - playerDirection > PI))) {
        facingDirection += turnSpeed * delta;
      } else {
        facingDirection -= turnSpeed * delta;
      }
      angle = abs(facingDirection - playerDirection) % PI;
    }
    return angle;
  }
  
  float walkTowardsPlayer(float delta) {
    last_refresh += delta;
    float distToPlayer = 1000;
    //update repulsors + attractors
    if (last_refresh > _ENTITY_REFRESH_TIME) {
      repulsors.clear();
      attractors.clear();
      for (Entity entity : entities) {
        if (entity instanceof Harmful) {
          repulsors.add(entity);
        }
        if (entity instanceof Player) {
          attractors.add(entity);
        }
      }
    }
    ArrayList<Float> directions = new ArrayList<Float>();
    ArrayList<Float> forces = new ArrayList<Float>();
    
    numEnemies = 12;
    float angleIncrement = TAU / numEnemies;
    float circleRadius = 200;
    Entity[] returnEnemies = new Entity[numEnemies];
    for (int i = 0; i < numEnemies; i++) {
      float xx = (width / 2) + (width / 2) * cos(angleIncrement * i);
      float yy = (height/ 2) + (height/ 2) * sin(angleIncrement * i);
      repulsors.add(new Harmful(xx, yy, 0, 16, 0, 0));
    }
    for (Entity repulsor : repulsors) {
      if (repulsor instanceof Harmful) {
        float dist = sqrt(sq(repulsor.x - x) + sq(repulsor.y - y)) - repulsor.radius -  radius;
        if (dist != 0) {
          forces.add(1 / sq(dist) * 5);
        }
      } 
      directions.add(atan2(-(repulsor.y - y), repulsor.x - x) + PI);
    }
    for (Entity attractor : attractors) {
      if (attractor instanceof Player) {
        float dist = sqrt(sq(attractor.x - x, 2) + sq(attractor.y - y)) - radius - attractor.radius;
        distToPlayer = dist;
        if (dist != 0) {
          forces.add(1 / dist);
        }     
      }
      directions.add(atan2(-(attractor.y - y), attractor.x - x));
    }
    //Add force away from edge of screen:
    /*
    float dx = x - (width/2);
    float dy = y - (height/2);
    forces.add(1f/sq(SPIKE_RADIUS - sqrt(dx*dx + dy*dy)));
    directions.add(atan2(dy, -dx));
    */
    float dirX = 0;
    float dirY = 0;
    for (int i = 0; i < directions.size(); i++) {
      dirX += cos(directions.get(i)) * forces.get(i);
      dirY += sin(directions.get(i)) * forces.get(i);
    }
    float direction = atan2(dirY, dirX);
    boolean onGrease = touchingGrease(x, y, radius);
    if (!onGrease) {
      friction = groundFriction;
      if (abs(velocityX) <= maxVelocity) {
        velocityX += acceleration * cos(direction) * delta;
      }
      if (abs(velocityY) <= maxVelocity) {
        velocityY -= acceleration * sin(direction) * delta;
      }
    } else {
      friction = 0;
      if (abs(velocityX) <= maxVelocity) {
        velocityX += greaseAcceleration * cos(direction) * delta;
      }
      if (abs(velocityY) <= maxVelocity) {
        velocityY -= greaseAcceleration * sin(direction) * delta;
      }
    }
    return distToPlayer;
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      if ((hp < lastHp) && ( hp > 0)) {
        lastHp = hp;
        addEntity(new HurtBox(this));
      } 
      if (hp <= 0) {
        score += value;
        for (int i = 0; i < 7; ++i) {
          Blood particle = new Blood(x, y);
          float direction = random(TAU);
          float velocity = random(200, 400);
          particle.velocityX = velocity * cos(direction);
          particle.velocityY = -velocity * sin(direction);
          addEntity(particle);
        }
        removeEntity(this);
        sounds["enemyDeath"].play();
      }
      /*
      int nFires = touchingFire(x, y, radius);
      if (nFires <= 2) {
        heat = max(heat - 1 * delta, 0);
      }
      else {
        heat += nFires * 1 * delta;
      }
      
      if (heat > 1) {
        hp -= 1 * delta;
      }
      */
    }
  }
  
  int depth() {
    return -50;
  }
  
  void hurt(float damage) {
    if (this instanceof BasicEnemy) {
      if (((BasicEnemy) this).reallyIsDashing) {
        return;
      }
    }
    if (this instanceof BigBasicEnemy) {
      if(((BigBasicEnemy) this).reallyIsDashing) {
        return;
      }
    }
    hp -= damage;
    sounds["enemyHurt"].play();
  }
  
  int value;
  float hp;
  float facingDirection;
  float acceleration;
  float maxVelocity;
  float groundFriction;
  float heat = 0;
  float turnSpeed;
  
  float lastHp;
  
   //References to other Entities (for walk())
  int _REPULSE_DIST = 20;
  float _ENTITY_REFRESH_TIME = 0.5; //seconds 
  float last_refresh = 0;
  ArrayList<Entity> repulsors = new ArrayList<Entity>();
  ArrayList<Entity> attractors = new ArrayList<Entity>();
  Entity player = null;
}
class Explosion extends ContinuousHarmful {
  
  Explosion(float x_, float y_) {
    super(x_, y_, 0, 0, 10);
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
  }
  
  void create() {
    super.create();
    if (explosionSheet == null) {
      explosionSheet = loadSpriteSheet("/LudumDare32/assets/explosion.png", 16, 1, 64, 64);
    }
    explosionAnimation = new Animation(explosionSheet, 0.04, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15);
    explosionAnimation.loop = false;
    sounds["explosion"].play();
  }
  
  void destroy() {
    super.destroy();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      explosionAnimation.update(delta);
      timer += delta;
      radius += growthRate * delta;
      if (radius > maxRadius) {
        radius = maxRadius;
      }
      if (timer > 0.64) {
        removeEntity(this);
      }
    }
  }
  
  void render() {
    super.render();
    explosionAnimation.drawAnimation(x - 32, y - 32, 64, 64);
  }
  
  int depth() {
    return -110;
  }
  
  float maxRadius = 64;
  float growthRate = 640;
  float timer = 0.0f;
  
  Animation explosionAnimation;
  
}

SpriteSheet explosionSheet;

// Similar to the Grease class, but calls applyFlameToMatrix instead
class Flame extends Moving {
  
  Flame(float x_, float y_) {
    super(x_, y_, FLAME_FRICTION);
  }
  
  void create() {
    super.create();
  }
  void destroy() {
    super.destroy();
  }
  void render() {
    noStroke();
    smallFireAnimations[0].drawAnimation(x - 4, y - 4, 8, 8);
    /*fill(FLAME_COLOR);
    ellipse(x, y, 2 * radius, 2 * radius);
    fill(255);
    stroke(0);*/
  }
  void update(int phase, float delta) {
    super.update(state, delta);
    if (phase == 0) {
      if(state == MOVING_STATE) {
        if(!isMoving()) {
          state = GROUND_STATE;
          applyFlameToMatrix(this);
        }
      } else {
        removeEntity(this);
      }
    }
  }
  boolean isMoving() {
    // Is the flame still flying through the air?
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
  
  float FLAME_FRICTION = 500;
}

color FLAME_COLOR = color(125, 20, 0);

FlameParticles[] flameSystems;

ArrayList<Particle> free = new ArrayList<Particle>();

void initFlameParticles() {
  flameSystems = new FlameParticles[10];
  for(int i = 0; i < 10; i ++) {
    flameSystems[i] = new FlameParticles();
  }
}

class FlameParticles {
  
  Particle generateParticle() {
    if(free.size() == 0) {
      return new Particle(systemWidth / 2, 0, random(-maxParticleVelX, maxParticleVelX), random(maxParticleVelY / 2, maxParticleVelY), particleLife);
    } else {
      Particle p = free.remove(free.size() - 1);
      p.init(systemWidth / 2, 0, random(-maxParticleVelX, maxParticleVelX), random(-maxParticleVelY / 2, -maxParticleVelY), particleLife);
      return p;
    }
  }
  
  void pseudoRender() {
    snapshot.background(0, 0);
    snapshot.beginDraw();
    for(Particle p : particles) {
      p.render(snapshot);
    }
    snapshot.endDraw();
  }
  
  void update(float delta) {
    timeCounter += delta;
    if(timeCounter > period) {
      timeCounter -= period;
      if(particles.size() < 10) {
        particles.add(generateParticle());
      }
    }
    for(int i = particles.size() - 1; i >= 0; i --) {
      if(particles.get(i).timeLeft < 0) {
        free.add(particles.remove(i));
      }
    }
    for(Particle p : particles) {
      p.update(delta);
    }
    pseudoRender();
  }

  boolean isDead() {
    return systemLife < 0 && particles.size() == 0;
  }

  PGraphics snapshot = createGraphics(systemWidth, systemHeight);

  float timeCounter = 0;
  
  float period = 3;
  float particleLife = 1;
  float maxParticleVelX = 10;
  float maxParticleVelY = 50;
  
  ArrayList<Particle> particles = new ArrayList<Particle>();
  int MAX_PARTICLES = 3;
}

float systemWidth = 256;
float systemHeight = 256;

color FLAME_COLOR = color(200, 55, 10);

class Particle {
  
  Particle(float x_, float y_, float xVel, float yVel, float life) {
    init(x_, y_, xVel, yVel, life);
  }
  
  void init(float x_, float y_, float xVel, float yVel, float life) {
    x = x_;
    y = y_;
    velocityX = xVel;
    velocityY = yVel;
    lifeTime = life;
    timeLeft = life;
  }
  
  // beginDraw() and endDraw() are called outside
  void render(PGraphics buffer) {
    buffer.ellipse(x, y, radius * (timeLeft / lifeTime), radius * (timeLeft / lifeTime) + 2);
  }
  
  void update(float delta) {
    timeLeft -= delta;
    x += velocityX * delta;
    y += velocityY * delta;
    velocity = sqrt(velocityX * velocityX + velocityY * velocityY);
    if (velocity > friction * delta) {
      velocityX -= velocityX / velocity * friction * delta;
      velocityY -= velocityY / velocity * friction * delta;
    }
    else {
      velocityX = 0;
      velocityY = 0;
    }
  }
  
  float friction = 200;
  float x;
  float y;
  float velocityX;
  float velocityY;
  float lifeTime;
  float timeLeft;
  float radius = 8;
}
class FlameShooter extends PhysicsCollider {
  int facing;
  boolean isFiring = false;
  float firingTime = 0;
  FlameShooter(float x_, float y_, int facingDirection_) {
    super(x_, y_, 10, 12, 500);
    facingDirection = facingDirection_ * TAU / 4;
    facing = facingDirection_ % 4;
    /*shape = createGraphics(radius * 2, radius * 2);
    shape.beginDraw();
    shape.beginShape();
    int nSpikes = 6;
    for (int i = 0; i < nSpikes; ++i) {
      float distance = i == 0 ? radius : radius * 0.5;
      float angle = TAU / nSpikes * i + facingDirection;
      shape.vertex(radius / 2 + distance * cos(angle), radius / 2 - distance * sin(angle));
    }
    shape.endShape(CLOSE);
    shape.endDraw();*/
  }
  
  void onCollision(Collider cOther, boolean wasHandled) {
    super.onCollision(cOther, wasHandled);
  }
  
  void create() {
    super.create();
    if (flameShooterSheet == null) {
      flameShooterSheet = loadSpriteSheet("/LudumDare32/assets/flame_shooter.png", 4, 1, 24, 24);
    }
  }
  
  void destroy() {
    super.destroy();
  }
  
  void render() {
    super.render();
    flameShooterSheet.drawSprite(facing, x - 12, y - 12, 24, 24);
    //image(shape, x - radius / 2, y - radius / 2);
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      if (isFiring) {
        Flame particle = new Flame(x, y);
        float velocity = SHOOT_VELOCITY + random(-SHOOT_VELOCITY_RANDOM, +SHOOT_VELOCITY_RANDOM);
        float angle = facingDirection + random(-SHOOT_ANGLE_RANDOM, +SHOOT_ANGLE_RANDOM);
        particle.velocityX = velocity * cos(angle);
        particle.velocityY = -velocity * sin(angle);
        addEntity(particle);
      }
      else {
        firingTime += delta;
        if (firingTime > 2) {
          isFiring = true;
        }
      }
    }
  }
  
  int depth() {
    return -70;
  }
  
  //PGraphics shape;
  float facingDirection;
  
  float SHOOT_VELOCITY = 300;
  float SHOOT_VELOCITY_RANDOM = 100;
  float SHOOT_ANGLE_RANDOM = 0.25;
}

SpriteSheet flameShooterSheet;

class FlameThrower extends Moving {
  
  FlameThrower(float x_, float y_) {
    super(x_, y_, FLAMETHROWER_FRICTION);
  }
  
  void create() {
    super.create();
  }
  void destroy() {
    super.destroy();
  }
  void render() {
    super.render();
  }
  void update(int phase, float delta) {
    super.update(state, delta);
    if (phase == 0) {
      applyFlameToMatrix(this);
      if (!isMoving()) {
        removeEntity(this);
      }
    }
  }
  boolean isMoving() {
    // Is the flame still flying through the air?
    if(abs(velocityX) < 0.1 & abs(velocityY) < 0.1) {
        return false;
    }
    return true;
  }
  
  int state = 0;
  float radius = 4;
  
  int MOVING_STATE = 0;
  int GROUND_STATE = 1;
  
  float FLAMETHROWER_FRICTION = 500;
}

class FlameThrowerEnemy extends EnemyEntity {
  FlameThrowerEnemy(float x_, float y_, float facingDirection_) {
    super(x_, y_, _MASS, _RADIUS, _FRICTION, _VALUE, _HP, facingDirection_, _ACCELERATION, _MAXVELOCITY, _GREASE_ACCELERATION, _TURN_SPEED);
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
  }
  
  float walkTowardsPlayer(float delta) {
    return super.walkTowardsPlayer(delta);
  }
  
  void create() {
    super.create();
    if (robotLeftSheet == null) {
      robotLeftSheet = loadSpriteSheet("/LudumDare32/assets/robot_left.png", 3, 1, 32, 32);
      robotRightSheet = loadSpriteSheet("/LudumDare32/assets/robot_right.png", 3, 1, 32, 32);
    }
    robotLeftAnimation = new Animation(robotLeftSheet, 0.1, 1, 2);
    robotRightAnimation = new Animation(robotRightSheet, 0.1, 1, 2);
  }
  
  void destroy() {
    super.destroy();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      robotLeftAnimation.time = 10 / sqrt(sq(velocityX) + sq(velocityY));
      robotRightAnimation.time = robotLeftAnimation.time;
      robotLeftAnimation.update(delta);
      robotRightAnimation.update(delta);
      walkTowardsPlayer(delta);
      turnTowardsPlayer(delta);
      if (player != null) {
        float deltaX = player.x - x;
        float deltaY = player.y - y;
        float distanceSq = sq(deltaX) + sq(deltaY);
        
        if (isFlaming) {
          flameThrowerTime += delta;
          FlameThrower flameThrower = new FlameThrower(x + radius * cos(facingDirection), y - radius * sin(facingDirection));
          flameThrower.velocityX = 200 * cos(facingDirection);
          flameThrower.velocityY = -200 * sin(facingDirection);
          addEntity(flameThrower);
          
          if (flameThrowerTime > _MAX_FLAME_TIME) {
            isFlaming = false;
          }
          
        }
        else if (isCharging) {
          chargeTime += delta;
          if (chargeTime > _MAX_CHARGE_TIME) {
            isCharging = false;
            isFlaming = true;
            flameThrowerTime = 0;
            sounds["robotShoot"].play();
          }
        }
        else {
          if (distanceSq < 128 * 128 && abs(angleBetween(facingDirection, atan2(-deltaY, deltaX))) < PI / 4) {
            isCharging = true;
            chargeTime = 0;
            addEntity(new ChargeBox(this, _MAX_CHARGE_TIME));
          }
        }
      }
    }
  }
  
  void render() {
    super.render();
    facingDirection = standardizeAngle(facingDirection);
    if (facingDirection < HALF_PI || facingDirection > 3 * HALF_PI) {
      robotRightAnimation.drawAnimation(x - 16, y - 16, 32, 32);
    }
    else {
      robotLeftAnimation.drawAnimation(x - 16, y - 16, 32, 32);
    }
  }
  
  //Basic Enemy properties
  float _MASS = 1;
  float _RADIUS = 16;
  int _VALUE = 5;
  float _HP = 10;
  float _ACCELERATION = 1200;
  float _GREASE_ACCELERATION = 200;
  float _FRICTION = 600;
  float _MAXVELOCITY = 25;
  float _TURN_SPEED = 0.5;
  
  float _MAX_FLAME_TIME = 2;
  float _MAX_CHARGE_TIME = 2;
  float flameThrowerTime = 0;
  float chargeTime = 0;
  float isFlaming = false;
  float isCharging = false;
  
  Animation robotLeftAnimation;
  Animation robotRightAnimation;
  
}

SpriteSheet robotLeftSheet;
SpriteSheet robotRightSheet;

class Grease extends Moving {
  
  Grease(float x_, float y_) {
    super(x_, y_, GREASE_FRICTION);
  }
  
  void create() {
    super.create();
    if (greaseImage == null) {
      greaseImage = loadImage("/LudumDare32/assets/grease_particle.png");
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
    sootImage = loadImage("/LudumDare32/assets/soot.png");
    largeFireSheet = loadSpriteSheet("/LudumDare32/assets/large_fire.png", 4, 1, 24, 24);
    mediumFireSheet = loadSpriteSheet("/LudumDare32/assets/medium_fire.png", 7, 1, 16, 16);
    smallFireSheet = loadSpriteSheet("/LudumDare32/assets/small_fire.png", 5, 1, 8, 8);
    
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


class Harmful extends PhysicsCollider{
  Harmful(float x_, float y_, float mass_, float radius_, float friction_, float damage_) {
    super(x_, y_, mass_, radius_, friction_);
    damage = damage_;
  }
  
  void onCollision(Collider cOther, boolean wasHandled) {
    super.onCollision(cOther, wasHandled);
  }
  
  void create() {
    super.create();
  }
  
  void destroy() {
    super.destroy();
  }
  
  void render() {
    super.render();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
  }
  
  float damage;
  
}
class Heart extends PhysicsCollider {
  Heart (float x_, float y_) {
    super (x_, y_, 200, 40, 50);
  }
  
  void onCollision(Collider cOther, boolean wasHandled) {
    super.onCollision(cOther, wasHandled);
    if (cOther instanceof Player){
      removeEntity(this);
    }
  }
  
  void create() {
    super.create();
  }
  
  void destroy() {
    super.destroy();
  }
  
  void render() {
    super.render();
    image(heartImage, x, y);
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
  }
}

PImage heartImage;
class HurtBox extends Moving {
  HurtBox(Entity entity_){
    super(entity_.x, entity_.y, 0);
    entity = entity_;
  }
  
  void create() {
    super.create();
  }
  
  void destroy() {
    super.destroy();
  }
  
  void render() {
    super.render();
    if (entity.exists) {
      fill(255, 50, 50, alpha);
      noStroke();
      rect(entity.x - entity.radius, 
           entity.y - entity.radius,
           entity.radius * 2, entity.radius * 2
      );
    } 
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      alpha = 100 * sin((2 * PI / 0.5) * (timer)) + 100;
      if (timer > stayTime) {
        removeEntity(this); 
      }
    }
    timer += delta;
  }
  
  int depth() {
    return -110;
  }
  
  int alpha = 255;
  int timer = 0;
  float stayTime = 1;
  Entity entity;
}
class Level {
  
  Level() {
  }
  
  Entity[] init() {
  }
  
  Entity[] initEnemies(int pointsValue) {
    Entity[] enemyTypes = new Entity []{
      new BasicEnemy(0, 0, 0),
      new BigBasicEnemy(0, 0, 0),
      new FlameThrowerEnemy(0, 0, 0),
      new ShootingEnemy(0, 0, 0),
      new BomberEnemy(0, 0, 0)
    };
    float pointCounter = pointsValue;
    ArrayList<Integer> enemies = new ArrayList<Integer>();
    int numEnemies = 0;
    while (pointCounter > 0) {
      r = int(random(0, enemyTypes.length));
      if (enemyTypes[r].value <= pointCounter) {
        enemies.add(r);
        numEnemies ++;
        pointCounter -= enemyTypes[r].value;
      }
    }
    Entity[] returnEnemies = new Entity[numEnemies];
    for (int i = 0; i < numEnemies; ++i) {
      float x;
      float y;
      do {
        x = random(width);
        y = random(height);
      } while (!isPositionValid(x, y));
      returnEnemies[i] = getEnemy(enemies.get(i), x, y);
    }
    /*float angleIncrement = TAU / numEnemies;
    float circleRadius = 200;
    Entity[] returnEnemies = new Entity[numEnemies];
    for (int i = 0; i < numEnemies; i++) {
        float x = (width / 2) + circleRadius * cos(angleIncrement * i);
        float y = (height/ 2) + circleRadius * sin(angleIncrement * i);
        if (enemies.get(i) == 1) {
          returnEnemies[i] = new BigBasicEnemy(x, y, random(TAU));
        } else if (enemies.get(i) == 2) {
          returnEnemies[i] = new FlameThrowerEnemy(x, y, random(TAU));
        } else if (enemies.get(i) == 3) {
          returnEnemies[i] = new ShootingEnemy(x, y, random(TAU));
        } else if (enemies.get(i) == 4) {
          returnEnemies[i] = new BomberEnemy(x, y, random(TAU));
        } else {
          returnEnemies[i] = new BasicEnemy(x, y, random(TAU));
        }
    }*/
    return returnEnemies;
  }
  
  void respawnLevelObjects(int pointsValue) {
    levelObjects = init();
    enemies = initEnemies(pointsValue);
  }
  
  boolean isPositionValid(float x, float y) {
    float centerDistance = sqrt(sq(x - width / 2) + sq(y - height / 2));
    if (centerDistance > width / 2 - 32 - 32 - 16 || centerDistance < 32 + 32 + 16) {
      return false;
    }
    for (Entity entity : levelObjects) {
      if (entity instanceof Moving) {
        Moving other = (Moving) entity;
        float distance = sqrt(sq(other.x - x) + sq(other.y - y));
        if (distance < other.radius + 32 + 16) {
          return false;
        }
      }
    }
    return true;
  }
  
  Entity[] levelObjects;
  Entity[] enemies;
  int nSpawners = 0;
  
}

EnemyEntity getEnemy(int i, float x, float y) {
  if (i == 1) {
    return new BigBasicEnemy(x, y, random(TAU));
  } else if (i == 2) {
    return new FlameThrowerEnemy(x, y, random(TAU));
  } else if (i == 3) {
    return new ShootingEnemy(x, y, random(TAU));
  } else if (i == 4) {
    return new BomberEnemy(x, y, random(TAU));
  } else {
    return new BasicEnemy(x, y, random(TAU));
  }
}

void spawnLevel(Level level, int pointsValue) {
  level.respawnLevelObjects(pointsValue);
  for (Entity entity : level.levelObjects) {
    addEntity(new Spawner(entity, level));
    ++level.nSpawners;
  }
  for (Entity entity : level.enemies) {
    addEntity(new Spawner(entity, level));
    ++level.nSpawners;
  }
  if (levelPointsValue != 4){
    addEntity(new Heart(width/2, height/2));
  }
  levelPointsValue += 2;
}

void despawnLevel(Level level) {
  for (Entity entity : level.levelObjects) {
    //Explosion explosion = new Explosion(entity.x, entity.y, entity.radius * 1.5);
    for (int i = 0; i < 5; ++i) {
      Grease particle = new Grease(entity.x, entity.y);
      float velocity = random(0, 400);
      float angle = random(0, TAU);
      particle.velocityX = velocity * cos(angle);
      particle.velocityY = -velocity * sin(angle);
      addEntity(particle);
    }
    //addEntity(explosion);
    
    removeEntity(entity);
  }
}

Level[] levels;

class Level1 extends Level {
  Entity[] init() {
    return new Entity[] {
      new RotatingSpikes(height / 2, width / 2, 32, 0, width / 2 - 128, PI / 8, 16),
      new RotatingSpikes(height / 2, width / 2, 32, PI / 2, width / 2 - 128, PI / 8, 16),
      new RotatingSpikes(height / 2, width / 2, 32, 3 * PI / 2, width / 2 - 128, PI / 8, 16),
      new RotatingSpikes(height / 2, width / 2, 32, PI, width / 2 - 128, PI / 8, 16)
    };
  }
}

class Level2 extends Level {
  Entity[] init() {
    Entity[] result = new Entity[8];
    for (int i = 0; i < 8; ++i) {
      float angle = TAU / 8 * i;
      result[i] = new Barrel(width / 2 + 256 * cos(angle), height / 2 - 256 * sin(angle));
    }
    return result;
  }
}

class Level3 extends Level {
  Entity[] init() {
    return new Entity[] {
      new FlameShooter(width - 128, height / 2, 2),
      new FlameShooter(128, height / 2, 0)
    };
  }
}

class Level4 extends Level {
  Entity[] init() {
    return new Entity[] {
      new Pillar(width / 2, 256, 32),
      new Pillar(width / 2, height - 256, 32),
      new Spikes(256, height / 2, 32, 16),
      new Spikes(width - 256, height / 2, 32, 16)
    };
  }
}

class Level5 extends Level {
  Entity[] init() {
    return new Entity[] {
      new FlameShooter(width / 2, 128, 3),
      new Barrel(width / 2 - 64, height - 128),
      new Barrel(width / 2, height - 128),
      new Barrel(width / 2 + 64, height - 128)
    };
  }
}

class Level6 extends Level {
  Entity[] init() {
    return new Entity[] {
      new Pillar(256, height / 2, 24),
      new Pillar(width - 256, height / 2, 24),
      new RotatingSpikes(256, height / 2, 16, PI, 64, PI / 3, 16),
      new RotatingSpikes(width - 256, height / 2, 16, 0, 64, -PI / 3, 16)
    };
  }
}

class Level7 extends Level {
  Entity[] init() {
    return new Entity[] {
      new Pillar(256, 256, 16),
      new Pillar(width - 256, 256, 16),
      new Pillar(256, height - 256, 16),
      new Pillar(width - 256, height - 256, 16)
    };
  }
}



class Moving extends Entity {
  
  Moving(float x_, float y_, float friction_) {
    x = x_;
    y = y_;
    friction = friction_;
  }
  
  void create() {
    super.create();
  }
  
  void destroy() {
    super.destroy();
  }
  
  void render() {
    super.render();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      x += velocityX * delta;
      y += velocityY * delta;
      velocity = sqrt(velocityX * velocityX + velocityY * velocityY);
      if (velocity > friction * delta) {
        velocityX -= velocityX / velocity * friction * delta;
        velocityY -= velocityY / velocity * friction * delta;
      }
      else {
        velocityX = 0;
        velocityY = 0;
      }
    }
  }
  
  float friction;
  float x;
  float y;
  float velocityX;
  float velocityY;
  
}
class PhysicsCollider extends Collider {
  PhysicsCollider(float x_, float y_, float mass_, float radius_, float friction_) {
    super(x_, y_, radius_, friction_);
    mass = mass_;
    kinematic = false;
  }
  
  void onCollision(Collider cOther, boolean wasHandled) {
    super.onCollision(cOther, wasHandled);
    if (wasHandled) {
      return;
    }
    if (cOther instanceof PhysicsCollider) {
      PhysicsCollider other = (PhysicsCollider) cOther;
      
      float deltaX = x - other.x;
      float deltaY = y - other.y;
      float deltaVelocityX = velocityX - other.velocityX;
      float deltaVelocityY = velocityY - other.velocityY;
      
      float dotProduct = deltaX * deltaVelocityX + deltaY * deltaVelocityY;
      float distanceSqr = deltaX * deltaX + deltaY * deltaY;
      
      float massFactor1 = 2 * other.mass / (mass + other.mass);
      float massFactor2 = 2 * mass / (mass + other.mass);
      
      if (dotProduct > 0) {
        return;
      }
      
      if (sq(deltaVelocityX) + sq(deltaVelocityY) > 50 * 50) {
        sounds["collision"].play();
      }
      
      if (kinematic) {
        massFactor1 = 0;
        massFactor2 = 2;
      }
      else if (other.kinematic) {
        massFactor1 = 2;
        massFactor2 = 0;
      }
      
      float factor1 = massFactor1 * dotProduct / distanceSqr;
      float factor2 = massFactor2 * dotProduct / distanceSqr;
      
      if (!kinematic) {
        velocityX -= factor1 * deltaX;
        velocityY -= factor1 * deltaY;
      }
      
      if (!other.kinematic) {
        other.velocityX += factor2 * deltaX;
        other.velocityY += factor2 * deltaY;
      }
    }
  }
  
  void hitEdge() {
  }
  
  void create() {
    super.create();
  }
  
  void destroy() {
    super.destroy();
  }
  
  void render() {
    super.render();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      float centerX = width / 2;
      float centerY = height / 2;
      float deltaX = x - centerX;
      float deltaY = y - centerY;
      float distanceSq = sq(deltaX) + sq(deltaY);
      float distance = sqrt(distanceSq);
      if (distanceSq > sq(SPIKE_RADIUS)) {
        x = SPIKE_RADIUS * deltaX / distance + centerX;
        y = SPIKE_RADIUS * deltaY / distance + centerY;
        float nx = -deltaX / distance;
        float ny = -deltaY / distance;
        float tx = -ny;
        float ty = nx;
        
        float iy = nx;
        float ix = tx;
        
        float jy = ny;
        float jx = tx;
        
        float transformedY = velocityX * nx + velocityY * ny;
        float transformedX = velocityX * tx + velocityY * ty;
        
        if (transformedY < 0) {
          transformedY = -transformedY;
        }
        
        velocityX = transformedX * ix + transformedY * iy;
        velocityY = transformedX * jx + transformedY * jy;
        
        hitEdge();
      }
    }
  }
  
  float mass;
  boolean kinematic;
  
}

class Pillar extends PhysicsCollider {
  
  int frame = 0;
  
  Pillar(float x_, float y_, float radius_) {
    super(x_, y_, 1, radius_, 1);
    kinematic = true;
    frame = floor(random(0, 2.999));
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
  }
  
  void create() {
    super.create();
    if (pillarSheet == null) {
      pillarSheet = loadSpriteSheet("/LudumDare32/assets/pillar.png", 3, 1, 128, 128);
    }
  }
  
  void destroy() {
    super.destroy();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
  }
  
  void render() {
    super.render();
    pillarSheet.drawSprite(frame, x - radius, y - radius, 2 * radius, 2 * radius);
  }
  
  int depth() {
    return -70;
  }
  
}

SpriteSheet pillarSheet;

class Player extends PhysicsCollider {
  Player(float x_, float y_) {
    super(x_, y_, 1, 16, FRICTION);
  }
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
    if (other instanceof Harmful || other instanceof ContinuousHarmful) {
      hurt();
    }
    if (other instanceof Heart) {
      hearts ++;
    }
  }
  void create() {
    super.create();
    if (playerLeftSheet == null) {
      playerLeftSheet = loadSpriteSheet("/LudumDare32/assets/hatguy_left.png", 5, 1, 32, 32);
      playerRightSheet = loadSpriteSheet("/LudumDare32/assets/hatguy_right.png", 5, 1, 32, 32);
      playerDashImage = loadImage("/LudumDare32/assets/player_dash.png");
      heartImage = loadImage("/LudumDare32/assets/heart.png");
    }
    playerLeftAnimation = new Animation(playerLeftSheet, 0.1, 1, 2, 3, 4);
    playerRightAnimation = new Animation(playerRightSheet, 0.1, 1, 2, 3, 4);
  }
  void destroy() {
    super.destroy();
  }
  
  void hitEdge() {
    super.hitEdge();
    hurt();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      if (invincibleTimer >= 0.0f) {
        invincibleTimer -= delta;
      }
      playerLeftAnimation.time = 10 / sqrt(sq(velocityX) + sq(velocityY));
      playerRightAnimation.time = playerLeftAnimation.time;
      playerLeftAnimation.update(delta);
      playerRightAnimation.update(delta);
      boolean isOnGrease = touchingGrease(x, y, radius);
      facingDirection = atan2(-(mouseY - y), mouseX - x);
      if (isOnGrease) {
        friction = FRICTION;
      }
      else {
        friction = FRICTION;
      }
      float acceleration = isOnGrease ? ACCELERATION / 2 : ACCELERATION;//isOnGrease ? GREASE_ACCELERATION : ACCELERATION;
      float maxVelocity = isOnGrease ? MAX_VELOCITY : MAX_VELOCITY / 10;
      if (isDashing && abs(velocityX) <= maxVelocity * 1.5 && abs(velocityY) <= maxVelocity * 1.5) {
        isDashing = false;
      }
      if (canFireSecondary) {
        boolean isWalking = (leftKeyPressed || rightKeyPressed || upKeyPressed || downKeyPressed);
        if (leftKeyPressed && velocityX > -maxVelocity) {
          velocityX -= acceleration * delta;
        }
        if (rightKeyPressed && velocityX < maxVelocity) {
          velocityX += acceleration * delta;
        }
        if (upKeyPressed && velocityY > -maxVelocity) {
          velocityY -= acceleration * delta;
        }
        if (downKeyPressed && velocityY < maxVelocity) {
          velocityY += acceleration * delta;
        }
        footstepTimer = min(0.4f * MAX_VELOCITY / sqrt(sq(velocityX) + sq(velocityY)), footstepTimer);
        if (isWalking) {
          if (footstepTimer <= 0.0) {
            sounds["footstep"].play();
            footstepTimer = 0.4;
          }
          else {
            footstepTimer -= delta;
          }
        }
        else {
          footstepTimer = 0.05f;
        }
      }
      if (shootKeyPressed) {
        Grease particle = new Grease(x, y);
        float velocity = SHOOT_VELOCITY + random(-SHOOT_VELOCITY_RANDOM, +SHOOT_VELOCITY_RANDOM);
        float angle = facingDirection + random(-SHOOT_ANGLE_RANDOM, +SHOOT_ANGLE_RANDOM);
        particle.velocityX = velocity * cos(angle);
        particle.velocityY = -velocity * sin(angle);
        addEntity(particle);
      }
      if (secondaryShootKeyPressed && canFireSecondary && !isDashing) {
        /*
        Flame particle = new Flame(x, y);
        float deltaX = mouseX - x;
        float deltaY = mouseY - y;
        float distance = sqrt(deltaX * deltaX + deltaY * deltaY);
        float velocity = sqrt(2 * particle.friction * distance);
        particle.velocityX = velocity * cos(facingDirection);
        particle.velocityY = -velocity * sin(facingDirection);
        addEntity(particle);
        canFireSecondary = false;
        */
        velocityX += 300 * cos(facingDirection);
        velocityY -= 300 * sin(facingDirection);
        isDashing = true;
        sounds["playerDash"].play();
        canFireSecondary = false;
      }
      if (!canFireSecondary) {
        secondaryFireTimer += delta;
        if (secondaryFireTimer > SECONDARY_RELOAD) {
          secondaryFireTimer = 0;
          canFireSecondary = true;
        }
      }
      
      int nFires = touchingFire(x, y, radius);
      if (nFires <= 2) {
        heat = max(heat - 1 * delta, 0);
      }
      else if (invincibleTimer < 0.0f) {
        heat += nFires * 1 * delta;
      }
      
      if (heat > 1) {
        hurt();
      }
    }
  }
  
  void render() {
    super.render();
    facingDirection = standardizeAngle(facingDirection);
    if (invincibleTimer >= 0.0f) {
      alpha(122);
    }
    if (facingDirection < HALF_PI || facingDirection > 3 * HALF_PI) {
      playerRightAnimation.drawAnimation(x - 16, y - 16, 32, 32);
    }
    else {
      playerLeftAnimation.drawAnimation(x - 16, y - 16, 32, 32);
    }
    alpha(255);
    if (isDashing) {
      translate(x, y);
      float angle = atan2(velocityY, velocityX);
      rotate(angle);
      image(playerDashImage, -24, -24);
      rotate(-angle);
      translate(-x, -y);
    }
    for (int i = 1; i <= hearts; ++i) {
      image(heartImage, width - i * (32 + 16), 16);
    }
    //ellipse(x, y, 2 * radius, 2 * radius);
    //line(x, y, x + radius * cos(facingDirection), y - radius * sin(facingDirection));
  }
  
  int depth() {
    return -100;
  }
  
  void hurt() {
    if (invincibleTimer < 0.0f) {
      hearts -= 1;
      heat = 0;
      invincibleTimer = 1.0f;
      sounds["playerDeath"].play();
      if (hearts <= 0) {
        kill();
      }
      else {
        sounds["enemyHurt"].play();
        addEntity(new HurtBox(this));
        for (int i = 0; i < 7; ++i) {
          Blood particle = new Blood(x, y);
          float direction = random(TAU);
          float velocity = random(200, 400);
          particle.velocityX = velocity * cos(direction);
          particle.velocityY = -velocity * sin(direction);
          addEntity(particle);
        }
      }
    }
  }
  
  void kill () {
    removeEntity(this);
    isPlayerDead = true;
    sounds["playerDeath"].play();
    for (int i = 0; i < 14; ++i) {
      Blood particle = new Blood(x, y);
      float direction = random(TAU);
      float velocity = random(200, 400);
      particle.velocityX = velocity * cos(direction);
      particle.velocityY = -velocity * sin(direction);
      addEntity(particle);
    }
  }
  
  float facingDirection = 0;
  float ACCELERATION = 1500;
  float GREASE_ACCELERATION = 200;
  float FRICTION = 500;
  float MAX_VELOCITY = 150;
  float secondaryFireTimer = 0;
  float heat = 0;
  boolean canFireSecondary = true;
  boolean isDashing = false;
  
  float SHOOT_VELOCITY = 200;
  float SHOOT_VELOCITY_RANDOM = 210;
  float SHOOT_ANGLE_RANDOM = 0.25;
  
  float SECONDARY_RELOAD = 0.5; //3
  
  float footstepTimer = 0.0f;
  
  float invincibleTimer = -1.0f;
  int hearts = 3;
  
  Animation playerLeftAnimation;
  Animation playerRightAnimation;
  
}

SpriteSheet playerLeftSheet;
SpriteSheet playerRightSheet;
PImage playerDashImage;
PImage heartImage;

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
// An enemy that shoots at you!
class ShootingEnemy extends EnemyEntity {
  
  // Constants
  final float _MASS = 1;
  final float _RADIUS = 16;
  final int _VALUE = 3;
  final float _HP = 10;
  final float _ACCELERATION = 1200;
  final float _GREASE_ACCELERATION = 200;
  final float _FRICTION = 600;
  final float _MAXVELOCITY = 50;
  final float _TURN_SPEED = 1;
  
  ShootingEnemy(float x_, float y_, float facingDirection_) {
    super(x_, y_, _MASS, _RADIUS, _FRICTION, _VALUE, _HP, facingDirection_, _ACCELERATION, _MAXVELOCITY, _GREASE_ACCELERATION, _TURN_SPEED);
    timeUntilNextFire = random(1.0f, 2.0f);
  }
  
  void onCollision (Collider cOther, boolean wasHandled) {
    super.onCollision(cOther, wasHandled);
  }
  
  void create () {
    super.create();
    if (ninjaLeftSheet == null) {
      ninjaLeftSheet = loadSpriteSheet("/LudumDare32/assets/ninja_left.png", 5, 1, 32, 32);
      ninjaRightSheet = loadSpriteSheet("/LudumDare32/assets/ninja_right.png", 5, 1, 32, 32);
    }
    ninjaLeftAnimation = new Animation(ninjaLeftSheet, 0.2, 1, 2, 3, 4);
    ninjaRightAnimation = new Animation(ninjaRightSheet, 0.2, 1, 2, 3, 4);
  }
  
  void destroy () {
    super.destroy();
  }
  
  void render () {
    super.render();
    facingDirection = standardizeAngle(facingDirection);
    if (facingDirection < HALF_PI || facingDirection > 3 * HALF_PI) {
      ninjaRightAnimation.drawAnimation(x - 16, y - 16, 32, 32);
    }
    else {
      ninjaLeftAnimation.drawAnimation(x - 16, y - 16, 32, 32);
    }
  }
  
  void hitEdge () {
    super.hitEdge();
  }
  
  float turnTowardsPlayer (float delta) {
    return super.turnTowardsPlayer(delta);
  }
  
  float walkTowardsPlayer (float delta) {
    return super.walkTowardsPlayer(delta);
  }
  
  float timeUntilNextFire;
  
  void update (int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      ninjaLeftAnimation.time = 10 / sqrt(sq(velocityX) + sq(velocityY));
      ninjaRightAnimation.time = ninjaLeftAnimation.time;
      ninjaLeftAnimation.update(delta);
      ninjaRightAnimation.update(delta);
      walkTowardsPlayer(delta);
      turnTowardsPlayer(delta);
      if (player != null) {
        float deltaX = player.x - x;
        float deltaY = player.y - y;
        float distanceSq = sq(deltaX) + sq(deltaY);
        if (isCharging) {
          chargeTime += delta;
          if (chargeTime > MAX_CHARGE_TIME) {
            addEntity(makeBullet());
            sounds["ninjaShoot"].play();
            isCharging = false;
            timeUntilNextFire = random(1.0f, 2.0f);
          }
        }
        else if (timeUntilNextFire <= 0 && abs(angleBetween(facingDirection, atan2(-deltaY, deltaX))) < PI / 4) {
          isCharging = true;
          chargeTime = 0;
          addEntity(new ChargeBox(this, MAX_CHARGE_TIME));
        } else {
          timeUntilNextFire -= delta;
        }
      }
    }
  }
  
  Bullet makeBullet () {
    float ang = facingDirection;
    
    ang = random(ang - PI/8, ang + PI/8);
    
    return new Bullet(x,y, 300*cos(ang), -300*sin(ang));
  }
  
  float MAX_CHARGE_TIME = 1;
  float isCharging = false;
  float chargeTime = 0;
  
  Animation ninjaLeftAnimation;
  Animation ninjaRightAnimation;
  
}

SpriteSheet ninjaLeftSheet;
SpriteSheet ninjaRightSheet;




class Spawner extends Collider {
  
  Spawner(Entity entity_, Level owner_) {
    super(entity_.x, entity_.y, entity_.radius, 0);
    owner = owner_;
    entity = entity_;
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
    if (ready && other instanceof Player) {
        ((Player) other).kill();
    }
  }
  
  void create() {
    super.create();
    if (portalSheet == null) {
      portalSheet = loadSpriteSheet("/LudumDare32/assets/portalLoop.png", 4, 1, 32, 32);
      prePortalSheet = loadSpriteSheet("/LudumDare32/assets/portalStart.png", 8, 1, 32, 32);
    }
    portalAnimation = new Animation(portalSheet, 0.2, 0, 1, 2, 3);
    prePortalAnimation = new Animation(prePortalSheet, 0.1, 0, 1, 2, 3, 4, 5, 6, 7);
    prePortalAnimation.loop = false;
    sounds["prepareSpawn"].play();
  }
  
  void destroy() {
    super.destroy();
    owner.nSpawners -= 1;
    sounds["spawn"].play();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      portalAnimation.update(delta);
      prePortalAnimation.update(delta);
      timeElapsed += delta;
      if (timeElapsed > 1.2) {
        ready = true;
      }
      if (ready) {
        addEntity(entity);
        removeEntity(this);
      }
    }
  }
  
  void render() {
    super.render();
    if (prePortalAnimation.sprites[prePortalAnimation.curr] == 7) {
      portalAnimation.drawAnimation(x - radius, y - radius, 2 * radius, 2 * radius);
    }
    else {
      prePortalAnimation.drawAnimation(x - radius, y - radius, 2 * radius, 2 * radius);
    }
  }
  
  int depth() {
    return -25;
  }
  
  float timeElapsed = 0;
  boolean ready = false;
  Level owner;
  Entity entity;
  Animation portalAnimation;
  Animation prePortalAnimation;
}

SpriteSheet portalSheet;
SpriteSheet prePortalSheet;

/* @pjs preload="/LudumDare32/assets/spike_wall.png" */
PImage spikeWallImage;

float SPIKE_RADIUS;

class SpikeWall extends Entity {
  
  SpikeWall() {
  }
  
  void create() {
    super.create();
    spikeWallImage = loadImage("/LudumDare32/assets/spike_wall.png");
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


class SpriteSheet {
  
  PImage[] sprites;
  
  SpriteSheet (PImage[] _sprites) {
    sprites = _sprites;
  }
  
  void drawSprite (int index, float xPos, float yPos, float xRad, float yRad) {
    image(sprites[index], xPos, yPos, xRad, yRad);
  }
}

// A class for automaticaly animating 
class Animation {
  SpriteSheet sheet;
  int[] sprites;
  float time;
  
  int curr;
  float timeElapsed;
  
  boolean loop = true;
  
  Animation (SpriteSheet _sheet, float _time, int... _sprites) {
    sheet = _sheet;
    time = _time;
    sprites = _sprites;
    timeElapsed = 0;
    curr = 0;
  }
  
  //Draws and updates the animation.
  void drawAnimation (float xPos, float yPos, float xRad, float yRad) {
    sheet.drawSprite(sprites[curr], xPos, yPos, xRad, yRad);
  }
  
  void update(float delta) {
    timeElapsed += delta;
    // Only move to the next frame when enough time has passed
    if (timeElapsed >= time) {
      curr++;
      if (loop) {
        curr %= sprites.length;
      }
      else {
        if (curr >= sprites.length) {
          curr = sprites.length - 1;
        }
      }
      timeElapsed = 0.0f;
    }
  }
  
  void reset () {
    curr = 0;
  }
}

/* Loads a SpriteSheet from image at filename with x columns of sprites and y rows of sprites. */
SpriteSheet loadSpriteSheet (String filename, int x, int y, int w, int h) {
  PImage img = loadImage(filename);
  
  PImage[] sprites = new PImage[x*y];
  
  int xSize = w;
  int ySize = h;
  
  int a = 0;
  for (int j = 0; j < y; j++) {
    for (int i = 0; i < x; i++) {
      sprites[a] = img.get(i*xSize,j*ySize, xSize, ySize);
      a++;
    }
  }
  return new SpriteSheet(sprites);
}







