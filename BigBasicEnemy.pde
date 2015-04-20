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
      skeletonLeftSheet = loadSpriteSheet("/assets/skeleton_left.png", 5, 1, 32, 32);
      skeletonRightSheet = loadSpriteSheet("/assets/skeleton_right.png", 5, 1, 32, 32);
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
      
      if (canDash) {
        if ((dist < _MAX_DIST_TO_DASH) && (angle < _MAX_ANGLE_TO_DASH)) {
          velocityX += cos(facingDirection) * _DASH_FORCE;
          velocityY -= sin(facingDirection) * _DASH_FORCE;
          canDash = false;
          dashTimer = 0;
        }
      } else {
        dashTimer += delta;
        if (dashTimer > _DASH_RELOAD) {
          canDash = true;
        }
      }
    }
  }

  //Basic Enemy properties
  float _MASS = 2;
  float _RADIUS = 32;
  int _VALUE = 5;
  float _HP = 10;
  float _ACCELERATION = 1000;
  float _GREASE_ACCELERATION = 100;
  float _FRICTION = 600;
  float _MAXVELOCITY = 50;
  float _TURN_SPEED = 0.5;
  
  float _MAX_DIST_TO_DASH = 50;
  float _MAX_ANGLE_TO_DASH = PI/4;
  float _DASH_FORCE = 500;
  float _DASH_RELOAD = 3;
  float dashTimer = 0;
  boolean canDash = true;
  
  Animation skeletonLeftAnimation;
  Animation skeletonRightAnimation;
}

SpriteSheet skeletonLeftSheet;
SpriteSheet skeletonRightSheet;

