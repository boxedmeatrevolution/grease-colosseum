class Entity {
  // Called when the entity is added to the game
  void create() {}
  // Called when the entity is removed from the game
  void destroy() {}
  // Called whenever the entity is to be rendered
  void render() {}
  // Called when the entity is to be updated
  void update(int phase, float delta) {}
  // The order in the render and update list of the entity
  int depth() {
    return 0;
  }
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

boolean leftKeyPressed = false;
boolean rightKeyPressed = false;
boolean upKeyPressed = false;
boolean downKeyPressed = false;

boolean shootKeyPressed = false;

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
    while (j > 0 && entities.get(j - 1).depth() < x.depth()) {
      entities.set(j, entities.get(j - 1));
      j -= 1;
    }
    entities.set(j, x);
  }
}

void setup () {
  size(800, 600);
  /*TestEntity entityA = new TestEntity(200, 310);
  TestEntity entityB = new TestEntity(400, 300);
  entityB.velocityX = -64;
  addEntity(entityA);
  addEntity(entityB);*/
  Player player = new Player(width / 2, height / 2);
  GreaseSurface surface = new GreaseSurface();
  addEntity(player);
  addEntity(surface);
}

var lastUpdate = Date.now();

void draw () {
  background(0, 0, 0);
  if (state == STATE_IN_GAME) {
    // Calculate the delta t
    var now = Date.now();
    var delta = now - lastUpdate;
    lastUpdate = now;
    
    // Add entities in the add queue
    for (Entity entity : entitiesToBeAdded) {
      entities.add(entity);
      if (entity instanceof Collider) {
        colliders.add(entity);
      }
      entity.create();
    }
    // Remove entities in the remove queue
    for (Entity entity : entitiesToBeRemoved) {
      entities.remove(entity);
      if (entity instanceof Collider) {
        colliders.remove(entity);
      }
      entity.destroy();
    }
    entitiesToBeAdded.clear();
    entitiesToBeRemoved.clear();
    // Entities are sorted by depth
    sortEntities();
    for (int updatePhase = firstUpdatePhase; updatePhase <= lastUpdatePhase; ++updatePhase) {
      // Update every entity
      for (Entity entity : entities) {
        entity.update(updatePhase, delta / 1000.0f);
      }
      // Find and handle collisions
      if (updatePhase == 0) {
        for (int i = 0; i < colliders.size() - 1; ++i) {
          Collider first = colliders.get(i);
          for (int j = i + 1; j < colliders.size(); ++j) {
            Collider second = colliders.get(j);
            if (first.collides(second)) {
              first.onCollision(second, false);
              second.onCollision(first, true);
            }
          }
        }
      }
    }
    // Render every entity
    for (Entity entity : entities) {
      entity.render();
    }
  }
}

// Handle input
void keyPressed() {
  if (keyCode == UP || key == 'w') {
    upKeyPressed = true;
  }
  else if (keyCode == DOWN || key == 's') {
    downKeyPressed = true;
  }
  else if (keyCode == LEFT || key == 'a') {
    leftKeyPressed = true;
  }
  else if (keyCode == RIGHT || key == 'd') {
    rightKeyPressed = true;
  }
  else if (key == 'f') {
    shootKeyPressed = true;
  }
}

void keyReleased() {
  if (keyCode == UP || key == 'w') {
    upKeyPressed = false;
  }
  else if (keyCode == DOWN || key == 's') {
    downKeyPressed = false;
  }
  else if (keyCode == LEFT || key == 'a') {
    leftKeyPressed = false;
  }
  else if (keyCode == RIGHT || key == 'd') {
    rightKeyPressed = false;
  }
  else if (key == 'f') {
    shootKeyPressed = false;
  }
}


