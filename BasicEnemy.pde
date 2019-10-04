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
      gremlinLeftSheet = loadSpriteSheet("./assets/gremlin_left.png", 5, 1, 32, 32);
      gremlinRightSheet = loadSpriteSheet("./assets/gremlin_right.png", 5, 1, 32, 32);
      enemyDashImage = loadImage("./assets/enemy_dash.png");
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
