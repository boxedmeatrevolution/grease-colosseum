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
      console.log(pointCounter);
      if (enemyTypes[r].value <= pointCounter) {
        enemies.add(r);
        numEnemies ++;
        pointCounter -= enemyTypes[r].value;
      }
    }
    float angleIncrement = TAU / numEnemies;
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
    }
    return returnEnemies;
  }
  
  void respawnLevelObjects(int pointsValue) {
    levelObjects = init();
    enemies = initEnemies(pointsValue);
  }
  
  Entity[] levelObjects;
  Entity[] enemies;
  int nSpawners = 0;
  
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
}

void despawnLevel(Level level) {
  for (Entity entity : level.levelObjects) {
    Explosion explosion = new Explosion(entity.x, entity.y, entity.radius * 1.5);
    for (int i = 0; i < 5; ++i) {
      /*Flame particle = new Flame(entity.x, entity.y);
      float velocity = random(0, 400);
      float angle = random(0, TAU);
      particle.velocityX = velocity * cos(angle);
      particle.velocityY = -velocity * sin(angle);
      addEntity(particle);*/
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
  /*
  Entity[] initEnemies() {
    return new Entity[] {
      new BasicEnemy(128, height / 2, 0),
      new BasicEnemy(width - 128, height / 2, 0)
    };
  }
  */
}

class Level2 extends Level {
  Entity[] init() {
    return new Entity[] {
      new Barrel(128, height / 2),
      new Barrel(width - 128, height / 2)
    };
  }
  /*
  Entity[] initEnemies() {
    return new Entity[] {
      new BasicEnemy(width / 2 - 128, height / 2, 0)
    };
  }
  */
}

class Level3 extends Level {
  Entity[] init() {
    return new Entity[] {
      new Barrel(width / 2, 128),
      new Spikes(width / 2, height - 128, 16, 8)
    };
  }
  /*
  Entity[] initEnemies() {
    return new Entity[] {
      new BasicEnemy(width / 2, height / 2 - 128, 0),
      new BasicEnemy(width / 2 - 128, height / 2, 0),
      new BasicEnemy(width / 2 + 128, height / 2, 0)
    };
  }
  */
}


