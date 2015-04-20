class Spawner extends Collider {
  
  Spawner(Entity entity_, Level owner_) {
    super(entity_.x, entity_.y, entity_.radius, 0);
    owner = owner_;
    entity = entity_;
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
    if (ready && other instanceof Player) {
        addEntity(new DeadBody(other.x, other.y, other.velocityX, other.velocityY, other.radius));
        removeEntity(other);
        isPlayerDead = true;
    }
  }
  
  void create() {
    super.create();
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
    fill(color(0, 255, 255));
    ellipse(x, y, 2 * radius, 2 * radius);
    fill(255);
  }
  
  float timeElapsed = 0;
  boolean ready = false;
  Level owner;
  Entity entity;
}

