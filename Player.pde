class Player extends PhysicsCollider {
  Player(float x_, float y_) {
    super(x_, y_, 1, 16, FRICTION);
  }
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
    if (other instanceof Harmful || other instanceof ContinuousHarmful) {
      kill();
    }
  }
  void create() {
    super.create();
    if (playerLeftSheet == null) {
      playerLeftSheet = loadSpriteSheet("/assets/hatguy_left.png", 5, 1, 32, 32);
      playerRightSheet = loadSpriteSheet("/assets/hatguy_right.png", 5, 1, 32, 32);
    }
    playerLeftAnimation = new Animation(playerLeftSheet, 0.1, 1, 2, 3, 4);
    playerRightAnimation = new Animation(playerRightSheet, 0.1, 1, 2, 3, 4);
  }
  void destroy() {
    super.destroy();
  }
  
  void hitEdge() {
    super.hitEdge();
    kill();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      playerLeftAnimation.time = 10 / sqrt(sq(velocityX) + sq(velocityY));
      playerRightAnimation.time = playerLeftAnimation.time;
      playerLeftAnimation.update(delta);
      playerRightAnimation.update(delta);
      boolean isOnGrease = touchingGrease(x, y, radius);
      facingDirection = atan2(-(mouseY - y), mouseX - x);
      if (isOnGrease) {
        friction = 0;
      }
      else {
        friction = FRICTION;
      }
      float acceleration = isOnGrease ? ACCELERATION / 2 : ACCELERATION;//isOnGrease ? GREASE_ACCELERATION : ACCELERATION;
      float maxVelocity = isOnGrease ? MAX_VELOCITY : MAX_VELOCITY / 10;
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
      if (secondaryShootKeyPressed && canFireSecondary) {
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
      else {
        heat += nFires * 1 * delta;
      }
      
      if (heat > 1) {
        kill();
      }
    }
  }
  
  void render() {
    super.render();
    facingDirection = standardizeAngle(facingDirection);
    if (facingDirection < HALF_PI || facingDirection > 3 * HALF_PI) {
      playerRightAnimation.drawAnimation(x - 16, y - 16, 32, 32);
    }
    else {
      playerLeftAnimation.drawAnimation(x - 16, y - 16, 32, 32);
    }
    //ellipse(x, y, 2 * radius, 2 * radius);
    //line(x, y, x + radius * cos(facingDirection), y - radius * sin(facingDirection));
  }
  
  int depth() {
    return -10;
  }
  
  void kill () {
    addEntity(new DeadBody(x, y, velocityX, velocityY, radius));
    removeEntity(this);
    isPlayerDead = true;
    sounds["playerDeath"].play();
    for (int i = 0; i < 7; ++i) {
      Blood particle = new Blood(x, y);
      float direction = random(TAU);
      float velocity = random(200, 400);
      particle.velocityX = velocity * cos(direction);
      particle.velocityY = -velocity * sin(direction);
      addEntity(particle);
    }
  }
  
  float facingDirection = 0;
  float ACCELERATION = 1200;
  float GREASE_ACCELERATION = 200;
  float FRICTION = 600;
  float MAX_VELOCITY = 150;
  float secondaryFireTimer = 0;
  float heat = 0;
  boolean canFireSecondary = true;
  
  float SHOOT_VELOCITY = 200;
  float SHOOT_VELOCITY_RANDOM = 210;
  float SHOOT_ANGLE_RANDOM = 0.25;
  
  float SECONDARY_RELOAD = 0.5; //3
  
  float footstepTimer = 0.0f;
  
  Animation playerLeftAnimation;
  Animation playerRightAnimation;
  
}

SpriteSheet playerLeftSheet;
SpriteSheet playerRightSheet;

