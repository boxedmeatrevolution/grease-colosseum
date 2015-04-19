class BasicEnemy extends EnemyEntity{
  BasicEnemy(float x_, float y_, float facingDirection_) {
    super(x_, y_, _MASS, _RADIUS, _FRICTION, _VALUE, _HP, facingDirection_, _ACCELERATION, _MAXVELOCITY);
  }
  
  void onCollision(Collider cOther, boolean wasHandled) {
    super.onCollision(cOther, wasHandled);
  }
  
  void create() {
    super.create();
  }
  
  void destroy() {
    super.destroy();
  }
  
  void render() {
    super.render();
    ellipse(x, y, 2 * radius, 2 * radius);
    line(x, y, x + radius * cos(facingDirection), y - radius * sin(facingDirection));
  }
  
  void walk(float delta) {
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
    velocityX += _ACCELERATION * cos(direction) * delta;
    velocityY -= _ACCELERATION * sin(direction) * delta;
    console.log(velocityX);
    if (abs(velocityX) >= _MAXVELOCITY) {
      velocityX = _MAXVELOCITY * (velocity / abs(velocity));
    }
    if (abs(velocityY) >= _MAXVELOCITY) {
      velocityY = _MAXVELOCITY * (velocity / abs(velocity));
    }
    text(direction, 0,300);
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      walk(delta);
    }
  }

  //Basic Enemy properties
  float _MASS = 1;
  float _RADIUS = 16;
  float _FRICTION = 600;
  int _VALUE = 5;
  float _HP = 1;
  float _ACCELERATION = 600;
  float _MAXVELOCITY = 50;

  //References to other Entities (for walk())
  int _REPULSE_DIST = 20;
  float _ENTITY_REFRESH_TIME = 1; //seconds 
  float last_refresh = 0;
  ArrayList<Entity> repulsors = new ArrayList<Entity>();
  ArrayList<Entity> attractors = new ArrayList<Entity>();
}
