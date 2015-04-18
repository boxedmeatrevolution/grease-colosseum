class TestEntity extends PhysicsCollider {
  TestEntity(float x, float y) {
    super(x, y, 1, 64, 0);
  }
  void create() {
    super.create();
  }
  void destroy() {
    super.destroy();
  }
  void update(int state, float delta) {
    super.update(state, delta);
  }
  void render() {
    ellipse(x, y, radius * 2, radius * 2);
  }
}


