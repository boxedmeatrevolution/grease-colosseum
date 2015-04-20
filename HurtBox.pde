class HurtBox extends Moving {
  HurtBox(Entity entity_){
    super(entity_.x, entity_.y, 0);
    entity = entity_;
  }
  
  void create() {
    super.create();
  }
  
  void destroy() {
    super.destroy();
  }
  
  void render() {
    super.render();
    if (entity.exists) {
      fill(255, 50, 50, alpha);
      noStroke();
      rect(entity.x - entity.radius, 
           entity.y - entity.radius,
           entity.radius * 2, entity.radius * 2
      );
    } 
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      alpha = 100 * sin((2 * PI / 0.5) * (timer)) + 100;
      if (timer > stayTime) {
        removeEntity(this); 
      }
    }
    timer += delta;
  }
  
  int depth() {
    return -110;
  }
  
  int alpha = 255;
  int timer = 0;
  float stayTime = 1;
  Entity entity;
}
