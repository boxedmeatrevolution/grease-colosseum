class Level {
  
  Level() {
  }
  
  Entity[] init() {
  }
  
  void respawnLevelObjects() {
    levelObjects = init();
    return levelObjects;
  }
  
  Entity[] levelObjects;
  
}

void spawnLevel(Level level) {
  Entity[] levelObjects = level.respawnLevelObjects();
  for (Entity entity : levelObjects) {
    addEntity(new Spawner(entity, level));
  }
}

void despawnLevel(Level level) {
  for (Entity entity : level.levelObjects) {
    Explosion explosion = new Explosion(entity.x, entity.y, entity.radius * 1.5);
    for (int i = 0; i < 5; ++i) {
      Flame particle = new Flame(entity.x, entity.y);
      float velocity = random(0, 400);
      float angle = random(0, TAU);
      particle.velocityX = velocity * cos(angle);
      particle.velocityY = -velocity * sin(angle);
      addEntity(particle);
    }
    addEntity(explosion);
    
    removeEntity(entity);
  }
}

Level[] levels;

class Level1 extends Level {
  Entity[] init() {
    return new Entity[] {
      new Spikes(128, 128, 32, 16),
      new Spikes(width - 128, 128, 32, 16),
      new Spikes(128, height - 128, 32, 16),
      new Spikes(width - 128, height - 128, 32, 16)
    };
  }
}

class Level2 extends Level {
  Entity[] init() {
    return new Entity[] {
      new Barrel(128, height / 2),
      new Barrel(width - 128, height / 2)
    };
  }
}

class Level3 extends Level {
  Entity[] init() {
    return new Entity[] {
      new Barrel(width / 2, 128),
      new Spikes(width / 2, height - 128, 16, 8)
    };
  }
}

