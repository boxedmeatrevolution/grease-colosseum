class ContinuousHarmful extends Collider{
  ContinuousHarmful(float x_, float y_, float radius_, float friction_, float damage_) {
    super(x_, y_, radius_, friction_);
    damage = damage_;
  }
  
  void onCollision(Collider cOther, boolean wasHandled) {
    super.onCollision(cOther, wasHandled);
  }
  
  void create() {
    super.create();
  }
  
  void destroy() {
    super.destroy();
  }
  
  void render() {
    super.render();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
  }
  
  float damage;
  
}
