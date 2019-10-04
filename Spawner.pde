class Spawner extends Collider {
  
  Spawner(Entity entity_, Level owner_) {
    super(entity_.x, entity_.y, entity_.radius, 0);
    owner = owner_;
    entity = entity_;
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
    if (ready && other instanceof Player) {
        ((Player) other).kill();
    }
  }
  
  void create() {
    super.create();
    if (portalSheet == null) {
      portalSheet = loadSpriteSheet("./assets/portalLoop.png", 4, 1, 32, 32);
      prePortalSheet = loadSpriteSheet("./assets/portalStart.png", 8, 1, 32, 32);
    }
    portalAnimation = new Animation(portalSheet, 0.2, 0, 1, 2, 3);
    prePortalAnimation = new Animation(prePortalSheet, 0.1, 0, 1, 2, 3, 4, 5, 6, 7);
    prePortalAnimation.loop = false;
    sounds["prepareSpawn"].play();
  }
  
  void destroy() {
    super.destroy();
    owner.nSpawners -= 1;
    sounds["spawn"].play();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      portalAnimation.update(delta);
      prePortalAnimation.update(delta);
      timeElapsed += delta;
      if (timeElapsed > 1.2) {
        ready = true;
      }
      if (ready) {
        addEntity(entity);
        removeEntity(this);
      }
    }
  }
  
  void render() {
    super.render();
    if (prePortalAnimation.sprites[prePortalAnimation.curr] == 7) {
      portalAnimation.drawAnimation(x - radius, y - radius, 2 * radius, 2 * radius);
    }
    else {
      prePortalAnimation.drawAnimation(x - radius, y - radius, 2 * radius, 2 * radius);
    }
  }
  
  int depth() {
    return -25;
  }
  
  float timeElapsed = 0;
  boolean ready = false;
  Level owner;
  Entity entity;
  Animation portalAnimation;
  Animation prePortalAnimation;
}

SpriteSheet portalSheet;
SpriteSheet prePortalSheet;

