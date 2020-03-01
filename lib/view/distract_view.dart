import 'package:flutter/material.dart';
import 'package:rmp_app/game/game.dart';

class DistractView extends StatelessWidget {
  final BoxGame game;

  DistractView(this.game);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              child: Text(
                "Break all the tan boxes!",
                style: theme.textTheme.headline5,
              ),
            ),
            Flexible(
              child: game.widget,
            )
          ],
        ));
  }
}
