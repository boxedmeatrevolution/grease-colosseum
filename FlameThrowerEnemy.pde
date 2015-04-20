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
      robotLeftSheet = loadSpriteSheet("/assets/robot_left.png", 3, 1, 32, 32);
      robotRightSheet = loadSpriteSheet("/assets/robot_right.png", 3, 1, 32, 32);
    }
    robotLeftAnimation = new Animation(robotLeftSheet, 0.1, 0, 1, 2);
    robotRightAnimation = new Animation(robotRightSheet, 0.1, 0, 1, 2);
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
        if (distanceSq < 128 * 128) {
          float deltaAngle = atan2(-deltaY, deltaX) - facingDirection;
          while (abs(deltaAngle) > TAU) {
            deltaAngle -= TAU * deltaAngle / abs(deltaAngle);
          }
          if (abs(deltaAngle) < PI / 4) {
            FlameThrower flameThrower = new FlameThrower(x + radius * cos(facingDirection), y - radius * sin(facingDirection));
            flameThrower.velocityX = 200 * cos(facingDirection);
            flameThrower.velocityY = -200 * sin(facingDirection);
            addEntity(flameThrower);
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
    fill(color(0, 255, 0));
    ellipse(x, y, 2 * radius, 2 * radius);
    line(x, y, x + radius * cos(facingDirection), y - radius * sin(facingDirection));
    fill(255);
  }
  
  //Basic Enemy properties
  float _MASS = 1;
  float _RADIUS = 16;
  int _VALUE = 5;
  float _HP = 5;
  float _ACCELERATION = 1200;
  float _GREASE_ACCELERATION = 200;
  float _FRICTION = 600;
  float _MAXVELOCITY = 25;
  float _TURN_SPEED = 0.5;
  
  Animation robotLeftAnimation;
  Animation robotRightAnimation;
  
}

SpriteSheet robotLeftSheet;
SpriteSheet robotRightSheet;

