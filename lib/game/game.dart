import 'dart:math';

import 'package:flame/anchor.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/position.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/material.dart';
import 'package:rmp_app/game/game_components.dart';

// Game Credit: luanpotter of the Flame Engine dev team

class BoxGame extends BaseGame {

  final Random rnd = new Random();
  static final TextConfig regularText = TextConfig(color: BasicPalette.white.color);
  static Size dimensions;

  final List<Crate> crates = [];
  final List<Explosion> explosions = [];

  double creationTimer = 0.0;
  num points = 0;

  @override
  void render(Canvas canvas) {
    canvas.save();

    crates.forEach((crate) {
      crate.render(canvas);
      canvas.restore();
      canvas.save();
    });

    explosions.forEach((explosion) {
      explosion.render(canvas);
      canvas.restore();
      canvas.save();
    });

    final String pointsText = points.toString();
    regularText.render(canvas, "Score: $pointsText", Position(20.0, dimensions.height - 10.0), anchor: Anchor.bottomLeft);
    canvas.restore();
    canvas.save();
  }

  @override
  void update(double t) {
    creationTimer += t;

    if (creationTimer >= 0.6) {
      creationTimer = 0.0;
      newCrate();
    }

    crates.forEach((crate) => crate.update(t));
    crates.removeWhere((crate) {
      bool destroy = crate.destroy();

      if (destroy)
        points -= 20;

      return destroy;
    });

    explosions.forEach((explosion) => explosion.update(t));
    explosions.removeWhere((explosion) => explosion.destroy());
  }


  @override
  void onTapDown(TapDownDetails details) {
    crates.removeWhere((crate) {
      final double diff = CRATE_SIZE / 2;
      final double dX = ((crate.x + diff) - details.globalPosition.dx).abs();
      final double dY = ((crate.y + diff) - details.globalPosition.dy).abs();

      final bool remove = (dX < diff && dY < diff);
      if (remove) {
        explosions.add(new Explosion(crate));
        points += 10;
      }

      return remove;
    });
  }


  @override
  void onDetach() {
    super.onDetach();
    points = 0;
    crates.clear();
    explosions.clear();
  }

  void newCrate() {
    final double x = (CRATE_SIZE / 2) + rnd.nextDouble() * (dimensions.width - CRATE_SIZE);
    crates.add(Crate(x, dimensions.height));
  }

  static Future<void> preload() async {
    dimensions = await Flame.util.initialDimensions();
    await Explosion.fetch();
  }
}