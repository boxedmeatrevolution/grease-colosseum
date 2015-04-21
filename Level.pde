class Level {
  
  Level() {
  }
  
  Entity[] init() {
  }
  
  Entity[] initEnemies(int pointsValue) {
    Entity[] enemyTypes = new Entity []{
      new BasicEnemy(0, 0, 0),
      new BigBasicEnemy(0, 0, 0),
      new FlameThrowerEnemy(0, 0, 0),
      new ShootingEnemy(0, 0, 0),
      new BomberEnemy(0, 0, 0)
    };
    float pointCounter = pointsValue;
    ArrayList<Integer> enemies = new ArrayList<Integer>();
    int numEnemies = 0;
    while (pointCounter > 0) {
      r = int(random(0, enemyTypes.length));
      if (enemyTypes[r].value <= pointCounter) {
        enemies.add(r);
        numEnemies ++;
        pointCounter -= enemyTypes[r].value;
      }
    }
    Entity[] returnEnemies = new Entity[numEnemies];
    for (int i = 0; i < numEnemies; ++i) {
      float x;
      float y;
      do {
        x = random(width);
        y = random(height);
      } while (!isPositionValid(x, y));
      returnEnemies[i] = getEnemy(enemies.get(i), x, y);
    }
    /*float angleIncrement = TAU / numEnemies;
    float circleRadius = 200;
    Entity[] returnEnemies = new Entity[numEnemies];
    for (int i = 0; i < numEnemies; i++) {
        float x = (width / 2) + circleRadius * cos(angleIncrement * i);
        float y = (height/ 2) + circleRadius * sin(angleIncrement * i);
        if (enemies.get(i) == 1) {
          returnEnemies[i] = new BigBasicEnemy(x, y, random(TAU));
        } else if (enemies.get(i) == 2) {
          returnEnemies[i] = new FlameThrowerEnemy(x, y, random(TAU));
        } else if (enemies.get(i) == 3) {
          returnEnemies[i] = new ShootingEnemy(x, y, random(TAU));
        } else if (enemies.get(i) == 4) {
          returnEnemies[i] = new BomberEnemy(x, y, random(TAU));
        } else {
          returnEnemies[i] = new BasicEnemy(x, y, random(TAU));
        }
    }*/
    return returnEnemies;
  }
  
  void respawnLevelObjects(int pointsValue) {
    levelObjects = init();
    enemies = initEnemies(pointsValue);
  }
  
  boolean isPositionValid(float x, float y) {
    float centerDistance = sqrt(sq(x - width / 2) + sq(y - height / 2));
    if (centerDistance > width / 2 - 32 - 32 - 16 || centerDistance < 32 + 32 + 16) {
      return false;
    }
    for (Entity entity : levelObjects) {
      if (entity instanceof Moving) {
        Moving other = (Moving) entity;
        float distance = sqrt(sq(other.x - x) + sq(other.y - y));
        if (distance < other.radius + 32 + 16) {
          return false;
        }
      }
    }
    return true;
  }
  
  Entity[] levelObjects;
  Entity[] enemies;
  int nSpawners = 0;
  
}

EnemyEntity getEnemy(int i, float x, float y) {
  if (i == 1) {
    return new BigBasicEnemy(x, y, random(TAU));
  } else if (i == 2) {
    return new FlameThrowerEnemy(x, y, random(TAU));
  } else if (i == 3) {
    return new ShootingEnemy(x, y, random(TAU));
  } else if (i == 4) {
    return new BomberEnemy(x, y, random(TAU));
  } else {
    return new BasicEnemy(x, y, random(TAU));
  }
}

void spawnLevel(Level level, int pointsValue) {
  level.respawnLevelObjects(pointsValue);
  for (Entity entity : level.levelObjects) {
    addEntity(new Spawner(entity, level));
    ++level.nSpawners;
  }
  for (Entity entity : level.enemies) {
    addEntity(new Spawner(entity, level));
    ++level.nSpawners;
  }
  if (levelPointsValue != 4){
    addEntity(new Heart(width/2, height/2));
  }
  levelPointsValue += 2;
}

void despawnLevel(Level level) {
  for (Entity entity : level.levelObjects) {
    //Explosion explosion = new Explosion(entity.x, entity.y, entity.radius * 1.5);
    for (int i = 0; i < 5; ++i) {
      Grease particle = new Grease(entity.x, entity.y);
      float velocity = random(0, 400);
      float angle = random(0, TAU);
      particle.velocityX = velocity * cos(angle);
      particle.velocityY = -velocity * sin(angle);
      addEntity(particle);
    }
    //addEntity(explosion);
    
    removeEntity(entity);
  }
}

Level[] levels;

class Level1 extends Level {
  Entity[] init() {
    return new Entity[] {
      new RotatingSpikes(height / 2, width / 2, 32, 0, width / 2 - 128, PI / 8, 16),
      new RotatingSpikes(height / 2, width / 2, 32, PI / 2, width / 2 - 128, PI / 8, 16),
      new RotatingSpikes(height / 2, width / 2, 32, 3 * PI / 2, width / 2 - 128, PI / 8, 16),
      new RotatingSpikes(height / 2, width / 2, 32, PI, width / 2 - 128, PI / 8, 16)
    };
  }
}

class Level2 extends Level {
  Entity[] init() {
    Entity[] result = new Entity[8];
    for (int i = 0; i < 8; ++i) {
      float angle = TAU / 8 * i;
      result[i] = new Barrel(width / 2 + 256 * cos(angle), height / 2 - 256 * sin(angle));
    }
    return result;
  }
}

class Level3 extends Level {
  Entity[] init() {
    return new Entity[] {
      new FlameShooter(width - 128, height / 2, 2),
      new FlameShooter(128, height / 2, 0)
    };
  }
}

class Level4 extends Level {
  Entity[] init() {
    return new Entity[] {
      new Pillar(width / 2, 256, 32),
      new Pillar(width / 2, height - 256, 32),
      new Spikes(256, height / 2, 32, 16),
      new Spikes(width - 256, height / 2, 32, 16)
    };
  }
}

class Level5 extends Level {
  Entity[] init() {
    return new Entity[] {
      new FlameShooter(width / 2, 128, 3),
      new Barrel(width / 2 - 64, height - 128),
      new Barrel(width / 2, height - 128),
      new Barrel(width / 2 + 64, height - 128)
    };
  }
}

class Level6 extends Level {
  Entity[] init() {
    return new Entity[] {
      new Pillar(256, height / 2, 24),
      new Pillar(width - 256, height / 2, 24),
      new RotatingSpikes(256, height / 2, 16, PI, 64, PI / 3, 16),
      new RotatingSpikes(width - 256, height / 2, 16, 0, 64, -PI / 3, 16)
    };
  }
}

class Level7 extends Level {
  Entity[] init() {
    return new Entity[] {
      new Pillar(256, 256, 16),
      new Pillar(width - 256, 256, 16),
      new Pillar(256, height - 256, 16),
      new Pillar(width - 256, height - 256, 16)
    };
  }
}



