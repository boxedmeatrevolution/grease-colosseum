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
      result[i] = new Barrel(width / 2 + 64 * cos(angle), height / 2 - 64 * sin(angle));
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


