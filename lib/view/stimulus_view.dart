import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rmp_app/model/stimulus.dart';

const Duration STIMULUS_DISPLAY_TIME = const Duration(seconds: 3);

class StimulusView extends StatelessWidget {

  final List<Stimulus> _stimuli;
  final VoidCallback _onComplete;

  StimulusView(this._stimuli, this._onComplete);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StimulusData(_stimuli, _onComplete),
      ),
    );
  }
}

class StimulusData extends StatefulWidget {

  final List<Stimulus> _stimuli;
  final VoidCallback _onComplete;

  StimulusData(this._stimuli, this._onComplete);

  @override
  State<StatefulWidget> createState() => _StimulusDataState(_stimuli, _onComplete);
}

class _StimulusDataState extends State<StimulusData> {

  final List<Stimulus> _stimuli;
  final VoidCallback _onComplete;
  num _index = 0;
  Stimulus _stimulus;


  _StimulusDataState(this._stimuli, this._onComplete);

  @override
  void initState() {
    super.initState();

    _stimulus = _stimuli[0];

    Timer(STIMULUS_DISPLAY_TIME, incrementSlide);
  }

  void incrementSlide() {
    setState(() {
      _index++;
      if (_index >= (_stimuli.length - 1)) {
        _onComplete();
        _index = -1;
        return;
      }

      _stimulus = _stimuli[_index];
      Timer(STIMULUS_DISPLAY_TIME, incrementSlide);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if (_index == -1) {
      return Text("Complete");
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image(
          image: AssetImage(_stimulus.path),
        ),
        Text(
          _stimulus.name,
          style: theme.textTheme.headline,
        ),
      ],
    );
  }
}
