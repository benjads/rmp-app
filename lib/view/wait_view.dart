import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class WaitView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(
                image: AssetImage("graphics/latinmem_logo.png"),
                height: 180.0,
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 2.0),
                child: Text(
                  "Latinmem Study",
                  style: theme.textTheme.headline3,
                ),
              ),
              Text(
                "University of California, Santa Cruz",
                style: theme.textTheme.subtitle1,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 40.0),
                child: Divider(),
              ),
              Text(
                "Please wait for other participants",
                style: theme.textTheme.subtitle1,
              ),
              StreamBuilder(
                stream: PackageInfo.fromPlatform().asStream(),
                builder: (context, infoSnapshot) {
                  if (!infoSnapshot.hasData) return Container();

                  final PackageInfo info = infoSnapshot.data;
                  final String version = info.version;

                  return Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Version: $version",
                      style: theme.textTheme.overline,
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
