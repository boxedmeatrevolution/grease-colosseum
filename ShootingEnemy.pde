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
      ninjaLeftSheet = loadSpriteSheet("./assets/ninja_left.png", 5, 1, 32, 32);
      ninjaRightSheet = loadSpriteSheet("./assets/ninja_right.png", 5, 1, 32, 32);
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




