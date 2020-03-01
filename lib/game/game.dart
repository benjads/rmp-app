import 'dart:math';

import 'package:flame/anchor.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/position.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/material.dart';
import 'package:rmp_app/game/game_components.dart';
import 'package:rmp_app/model/participant.dart';

// Game Credit: luanpotter of the Flame Engine dev team

class BoxGame extends BaseGame {

  final Random rnd = new Random();
  static final TextConfig regularText = TextConfig(color: BasicPalette.white.color);
  static Size dimensions;

  final Participant _participant;
  final List<Crate> crates = [];
  final List<Explosion> explosions = [];

  double goodCreationTimer = 0.0, badCreationTimer = 0.0;
  num points = 0;

  BoxGame(this._participant);

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
    regularText.render(canvas, "Score: $pointsText", Position(5.0, 5.0), anchor: Anchor.topLeft);
    canvas.restore();
    canvas.save();

    canvas.restore();
  }

  @override
  void update(double t) {
    goodCreationTimer += t;
    badCreationTimer += t;

    if (goodCreationTimer >= 0.6) {
      goodCreationTimer = 0.0;
      newCrate(false);
    }

    if (badCreationTimer >= 2.0) {
      badCreationTimer = 0.0;
      newCrate(true);
    }

    crates.forEach((crate) => crate.update(t));
    crates.removeWhere((crate) {
      bool destroy = crate.destroy();

      if (destroy && !crate.badCrate)
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
      final double dX = ((crate.x + diff) - details.localPosition.dx).abs();
      final double dY = ((crate.y + diff) - details.localPosition.dy).abs();

      final bool remove = (dX < diff && dY < diff);
      if (remove) {
        explosions.add(new Explosion(crate));
        points += crate.badCrate ? -30 : 10;
      }

      return remove;
    });
  }

  @override
  void onDetach() {
    super.onDetach();
    _participant.gameScore = points;
    points = 0;
    crates.clear();
    explosions.clear();
  }

  void newCrate(bool badCrate) {
    final double x = (CRATE_SIZE / 2) + rnd.nextDouble() * (dimensions.width - CRATE_SIZE);
    crates.add(Crate(x, dimensions.height, badCrate));
  }

  static Future<void> preload() async {
    dimensions = await Flame.util.initialDimensions();
    await Explosion.fetch();
  }
}