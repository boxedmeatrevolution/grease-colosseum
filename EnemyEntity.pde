class EnemyEntity extends PhysicsCollider{
  EnemyEntity(float x_, float y_, float mass_, float radius_, float friction_, 
              int value_, float hp_, float facingDirection_, float acceleration_,
              float maxVelocity_, float grease_acceleration_) {
    super(x_, y_, mass_, radius_, friction_);
    value = value_;
    hp = hp_;
    facingDirection = facingDirection_;
    acceleration = acceleration_;
    maxVelocity = maxVelocity_;
    groundFriction = friction_;
    grease_acceleration = grease_acceleration_;
  }
  
  void onCollision(Collider cOther, boolean wasHandled) {
    super.onCollision(cOther, wasHandled);
    if (cOther instanceof Harmful) {
      hp -= ((Harmful) cOther).damage;
    }
    if (cOther instanceof ContinuousHarmful) {
      hp -= ((ContinuousHarmful) cOther).damage * timeDelta;
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
  
  void walkTowardsPlayer(float delta) {
    last_refresh += delta;
    //update repulsors + attractors
    if (last_refresh > _ENTITY_REFRESH_TIME) {
      repulsors.clear();
      attractors.clear();
      for (Entity entity : entities) {
        if ((entity instanceof Flame) || (entity instanceof Harmful)) {
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
        dist = sqrt(sq(repulsor.x - x) + sq(repulsor.y - y)) - repulsor.radius -  radius;
        forces.add(1 / sq(dist));
      }
      if (repulsor instanceof Flame) {
        dist = (sqrt(sq(repulsor.x - x) + sq(repulsor.y - y)) - radius < _REPULSE_DIST);
        forces.add(1 / sq(dist));
      }
      directions.add(atan2(-(repulsor.y - y), repulsor.x - x) + PI);
    }
    for (Entity attractor : attractors) {
      if (attractor instanceof Player) {
        dist = sqrt(sq(attractor.x - x, 2) + sq(attractor.y - y)) - radius - attractor.radius;
        text(dist, 0, 340);
        forces.add(1 / dist);
        directions.add(atan2(-(attractor.y - y), attractor.x - x));
      }
    }
    dirX = 0;
    dirY = 0;
    for (int i = 0; i < directions.size(); i++) {
      dirX += cos(directions.get(i)) * forces.get(i);
      dirY += sin(directions.get(i)) * forces.get(i);
      console.log(str(directions.get(i)) +  str(forces.get(i)));
    }
    direction = atan2(dirY, dirX);
    boolean onGrease = touchingGrease(x, y, radius);
    if (!onGrease) {
      friction = groundFriction;
      if (abs(velocityX) <= maxVelocity) {
        velocityX += acceleration * cos(direction) * delta;
        velocityY -= acceleration * sin(direction) * delta;
      }
    } else {
      friction = 0;
      if (abs(velocityX) <= maxVelocity) {
        velocityX += grease_acceleration * cos(direction) * delta;
        velocityY -= grease_acceleration * sin(direction) * delta;
      }
    }
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      if (hp <= 0) {
        addEntity(new DeadBody(x, y, velocityX, velocityY, radius));
        score += value;
        removeEntity(this);
      }
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
    }
  }
  
  int value;
  float hp;
  float facingDirection;
  float acceleration;
  float maxVelocity;
  float groundFriction;
  float heat = 0;
  
   //References to other Entities (for walk())
  int _REPULSE_DIST = 20;
  float _ENTITY_REFRESH_TIME = 1; //seconds 
  float last_refresh = 0;
  ArrayList<Entity> repulsors = new ArrayList<Entity>();
  ArrayList<Entity> attractors = new ArrayList<Entity>();
}
