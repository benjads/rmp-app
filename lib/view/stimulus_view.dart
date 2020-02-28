import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rmp_app/model/participant.dart';
import 'package:rmp_app/model/stimulus.dart';

const Duration STIMULUS_DISPLAY_TIME = const Duration(seconds: 3);
const num COUNTDOWN_SECS = 3;

class StimulusView extends StatelessWidget {
  final Participant _participant;
  final List<Stimulus> _stimuli;
  final Function _onComplete;

  StimulusView(this._participant, this._stimuli, this._onComplete);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: StimulusData(_participant, _stimuli, _onComplete),
        ),
      ),
    );
  }
}

class StimulusData extends StatefulWidget {
  final Participant _participant;
  final List<Stimulus> _stimuli;
  final Function _onComplete;

  StimulusData(this._participant, this._stimuli, this._onComplete);

  @override
  State<StatefulWidget> createState() =>
      _StimulusDataState(_participant, _stimuli, _onComplete);
}

class _StimulusDataState extends State<StimulusData> {
  static const Duration SECOND = const Duration(seconds: 1);

  final Participant _participant;
  final List<Stimulus> _stimuli;
  final Function _onComplete;

  num _index = 0;
  bool _started = false;
  num _countdown = -1;
  Timer _timer;

  _StimulusDataState(this._participant, this._stimuli, this._onComplete);

  void incrementSlide() {
    setState(() {
      _index++;
      if (_index > (_stimuli.length - 1)) {
        _onComplete(_participant);
        return;
      }

      _timer = Timer(STIMULUS_DISPLAY_TIME, incrementSlide);
    });
  }

  void decrementCountdown() {
    setState(() {
      _countdown--;

      if (_countdown == 0) {
        _started = true;
        _timer = Timer(STIMULUS_DISPLAY_TIME, incrementSlide);
      } else {
        _timer = Timer(SECOND, decrementCountdown);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    if (_timer != null && _timer.isActive) _timer.cancel();
    _index = 0;
    _started = false;
    _countdown = -1;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if (_participant.stageComplete) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Section Completed",
            style: theme.textTheme.headline5,
          ),
          Text(
            "Please wait...",
            style: theme.textTheme.subtitle1,
          )
        ],
      );
    }

    if (!_started) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 20.0),
            child: Text(
              "Several slides will be shown once you click \"Start\"." +
                  " Try to memorize them as best as you can.",
              style: theme.textTheme.headline5,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 130.0,
            width: 130.0,
            child: _countdown == -1
                ? RaisedButton(
                    color: theme.accentColor,
                    child: Text(
                      "START",
                      style: theme.textTheme.button
                          .copyWith(color: Colors.white, fontSize: 20.0),
                    ),
                    shape: CircleBorder(),
                    onPressed: () => setState(() {
                      _countdown = COUNTDOWN_SECS;
                      _timer = Timer(SECOND, decrementCountdown);
                    }),
                  )
                : Material(
                    color: theme.accentColor,
                    shape: CircleBorder(),
                    child: Center(
                      child: Text(
                        _countdown.toString(),
                        style: theme.textTheme.button
                            .copyWith(color: Colors.white, fontSize: 40.0),
                      ),
                    ),
                  ),
          ),
        ],
      );
    }

    final bool mnemonic = _participant.condition == Condition.MNEMONIC;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 250.0,
          width: double.infinity,
          child: Image(
              image: mnemonic
                  ? _stimuli[_index].mnemonicImage
                  : _stimuli[_index].standardImage),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            _stimuli[_index].name,
            style:
            theme.textTheme.headline4.copyWith(fontWeight: FontWeight.w700, color: Colors.black, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ),
        if (mnemonic)
          Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text(
              _stimuli[_index].mnemonicName,
              style: theme.textTheme.headline4.copyWith(fontWeight: FontWeight.w700, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          )
      ],
    );
  }
}
