import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';

const CRATE_SIZE = 128.0;

class Crate extends SpriteComponent {
  static const SPEED = 250.0;

  double maxY;

  Crate(double x, this.maxY) : super.square(CRATE_SIZE, "crate.png") {
    this.angle = 0.0;
    this.x = x;
    this.y = 150.0;
  }

  @override
  void update(double t) {
    y += t * SPEED;
  }

  @override
  bool destroy() {
    return y >= maxY + (CRATE_SIZE / 2);
  }
}

class Explosion extends PositionComponent {

  static const TIME = 0.75;

  static final Paint paint = new Paint()..color = Color(0xffffffff);
  static final List<Image> images = [];

  double lifetime = 0.0;

  Explosion(Crate crate) {
    this.x = crate.x;
    this.y = crate.y;
  }

  static fetch() async {
    for (var i = 0; i <= 6; i++)
      images.add(await Flame.images.load("explosion-${i.toString()}.png"));
  }

  @override
  void render(Canvas canvas) {
    canvas.translate(x + (CRATE_SIZE / 2), y + (CRATE_SIZE / 2));
    final num i = (6 * lifetime / TIME).round();
    final Image image = images[i];
    assert(images.length > i && images[i] != null);
    final Rect src = new Rect.fromLTWH(0.0, 0.0, image.width.toDouble(), image.height.toDouble());
    canvas.drawImageRect(image, src, src, paint);
  }

  @override
  void update(double t) {
    this.lifetime += t;
  }

  @override
  bool destroy() {
    return this.lifetime >= TIME;
  }


}
