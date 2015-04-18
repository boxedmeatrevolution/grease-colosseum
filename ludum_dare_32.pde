abstract class Entity {
  // Called when the entity is added to the game
  abstract void create();
  // Called when the entity is removed from the game
  abstract void destroy();
  // Called whenever the entity is to be rendered
  abstract void render();
  // Called when the entity is to be updated
  abstract void update(int phase, float delta);
  // The order in the render and update list of the entity
  abstract int depth();
}

int firstUpdatePhase = 0;
int lastUpdatePhase = 0;

int STATE_IN_GAME = 1;
int STATE_LOADING = 0;
int state = STATE_IN_GAME;

ArrayList<Entity> entities = new ArrayList<Entity>();
ArrayList<Entity> entitiesToBeAdded = new ArrayList<Entity>();
ArrayList<Entity> entitiesToBeRemoved = new ArrayList<Entity>();
ArrayList<Collider> colliders = new ArrayList<Collider>();

void addEntity(Entity entity) {
  entitiesToBeAdded.add(entity);
}

void removeEntity(Entity entity) {
  entitiesToBeRemoved.add(entity);
}

void sortEntities() {
  for (int i = 1; i < entities.size(); ++i) {
    Entity x = entities.get(i);
    int j = i;
    while (j > 0 && entities.get(j - 1).depth() > x.depth()) {
      entities.set(j, entities.get(j - 1));
      j -= 1;
    }
    entities.set(j, x);
  }
}

void setup () {
  size(800, 600);
}

var lastUpdate = Date.now();

void draw () {
  if (state == STATE_IN_GAME) {
    var now = Date.now();
    var delta = now - lastUpdate;
    lastUpdate = now;
    
    for (Entity entity : entitiesToBeAdded) {
      entities.add(entity);
      if (entity instanceof Collider) {
        colliders.add(entity);
      }
      entity.create();
    }
    for (Entity entity : entitiesToBeRemoved) {
      entities.remove(entity);
      if (entity instanceof Collider) {
        colliders.remove(entity);
      }
      entity.destroy();
    }
    entitiesToBeAdded.clear();
    entitiesToBeRemoved.clear();
    sortEntities();
    for (int updatePhase = firstUpdatePhase; updatePhase <= lastUpdatePhase; ++updatePhase) {
      for (Entity entity : entities) {
        entity.update(updatePhase, delta);
      }
      if (updatePhase == 0) {
        for (int i = 0; i < colliders.size() - 1; ++i) {
          Collider first = colliders.get(i);
          for (int j = i + 1; j < colliders.size(); ++j) {
            Collider second = colliders.get(j);
            if (first.collides(second)) {
              first.onCollision(second);
              second.onCollision(first);
            }
          }
        }
      }
    }
    for (Entity entity : entities) {
      entity.render();
    }
  }
}


