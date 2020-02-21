import 'package:flutter/material.dart';
import 'package:rmp_app/game/game.dart';

class DistractView extends StatelessWidget {

  final BoxGame game;

  DistractView(this.game);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: game.widget
    );
  }

}