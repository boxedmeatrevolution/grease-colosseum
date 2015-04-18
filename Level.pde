class Level {
  
  Level(Entity[] levelObjects_) {
    levelObjects = levelObjects_;
  }
  
  Entity[] levelObjects;
  
}

void spawnLevel(Level level) {
  console.log(str(level == null));
  console.log(str(level.levelObjects == null));
  for (Entity entity : level.levelObjects) {
    addEntity(new Spawner(entity, level));
  }
}

void despawnLevel(Level level) {
  for (Entity entity : level.levelObjects) {
    removeEntity(entity);
  }
}

Level[] levels;

