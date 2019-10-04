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
      dwarfLeftSheet = loadSpriteSheet("./assets/dwarf_left.png", 5, 1, 32, 32);
      dwarfRightSheet = loadSpriteSheet("./assets/dwarf_right.png", 5, 1, 32, 32);
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

