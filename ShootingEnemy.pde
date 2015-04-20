// An enemy that shoots at you!
class ShootingEnemy extends EnemyEntity {
  
  // Constants
  final float _MASS = 1;
  final float _RADIUS = 16;
  final int _VALUE = 5;
  final float _HP = 1;
  final float _ACCELERATION = 1200;
  final float _GREASE_ACCELERATION = 200;
  final float _FRICTION = 600;
  final float _MAXVELOCITY = 50;
  final float _TURN_SPEED = 1;
  
  ShootingEnemy(float x_, float y_, float facingDirection_) {
    super(x_, y_, _MASS, _RADIUS, _FRICTION, _VALUE, _HP, facingDirection_, _ACCELERATION, _MAXVELOCITY, _GREASE_ACCELERATION, _TURN_SPEED);
    timeUntilNextFire = random(50, 100);
  }
  
  void onCollision (Collider cOther, boolean wasHandled) {
    super.onCollision(cOther, wasHandled);
  }
  
  void create () {
    super.create();
    if (ninjaLeftSheet == null) {
      ninjaLeftSheet = loadSpriteSheet("/assets/ninja_left.png", 5, 1, 32, 32);
      ninjaRightSheet = loaderSpriteSheet("/assets/ninja_right.png", 5, 1, 32, 32);
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
  
  int timeUntilNextFire;
  
  void update (int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      ninjaLeftAnimation.time = 10 / sqrt(sq(velocityX) + sq(velocityY));
      ninjaRightAnimation.time = ninjaLeftAnimation.time;
      ninjaLeftAnimation.update(delta);
      ninjaRightAnimation.update(delta);
      walkTowardsPlayer(delta);
      turnTowardsPlayer(delta);
      if (timeUntilNextFire <= 0) {
        timeUntilNextFire = random(50, 100);
        
        if (player != null){
          addEntity(makeBullet());
        }
      } else {
        timeUntilNextFire--;
      }
    }
  }
  
  Bullet makeBullet () {
    float ang = facingDirection;
    
    ang = random(ang - PI/12, ang + PI/12);
    
    return new Bullet(x,y, 20*cos(ang), -20*sin(ang), 15);
  }
  
  Animation ninjaLeftAnimation;
  Animation ninjaRightAnimation;
  
}

SpriteSheet ninjaLeftSheet;
SpriteSheet ninjaRightSheet;




