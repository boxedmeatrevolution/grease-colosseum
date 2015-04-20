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
      hp -= ((Harmful) cOther).damage;
      sounds["enemyHurt"].play();
    }
    if (cOther instanceof ContinuousHarmful) {
      hp -= ((ContinuousHarmful) cOther).damage * timeDelta;
      sounds["enemyHurt"].play();
    }
  }
  
  void create() {
    super.create();
  }
  
  void destroy() {
    super.destroy();
    sounds["enemyDeath"].play();
  }
  
  void render() {
    super.render();
  }
  
  void hitEdge() {
    super.hitEdge();
    hp -= 5;
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
    for (Entity repulsor : repulsors) {
      if (repulsor instanceof Harmful) {
        float dist = sqrt(sq(repulsor.x - x) + sq(repulsor.y - y)) - repulsor.radius -  radius;
        if (dist != 0) {
          forces.add(1 / sq(dist));
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
        addEntity(new DeadBody(x, y, velocityX, velocityY, radius));
        score += value;
        removeEntity(this);
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
