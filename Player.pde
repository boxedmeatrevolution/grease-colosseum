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
      playerLeftSheet = loadSpriteSheet("./assets/hatguy_left.png", 5, 1, 32, 32);
      playerRightSheet = loadSpriteSheet("./assets/hatguy_right.png", 5, 1, 32, 32);
      playerDashImage = loadImage("./assets/player_dash.png");
      heartImage = loadImage("./assets/heart.png");
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

