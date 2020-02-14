import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rmp_app/model/participant.dart';
import 'package:rmp_app/model/stimulus.dart';

const num COUNTDOWN_SECS = 3;

class TestView extends StatelessWidget {
  final Participant _participant;
  final List<Stimulus> _stimuli;
  final List<String> _fakeStimuli;
  final Function _onComplete;

  TestView(
      this._participant, this._stimuli, this._fakeStimuli, this._onComplete);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: WordList(_participant, _stimuli, _fakeStimuli, _onComplete),
        ),
      ),
    );
  }
}

class WordList extends StatefulWidget {
  final Participant _participant;
  final List<Stimulus> _stimuli;
  final List<String> _fakeStimuli;
  final Function _onComplete;

  WordList(
      this._participant, this._stimuli, this._fakeStimuli, this._onComplete);

  @override
  State<StatefulWidget> createState() =>
      _WordListState(_participant, _stimuli, _fakeStimuli, _onComplete);
}

class _WordListState extends State<WordList> {
  static const Duration SECOND = const Duration(seconds: 1);

  final Participant _participant;
  final List<Stimulus> _stimuli;
  final List<String> _fakeStimuli;
  final Function _onComplete;

  final List<String> _wordList = [];
  final List<String> _chosen = [];

  bool _started = false;
  num _countdown = -1;
  Stopwatch _stopwatch = new Stopwatch();
  Timer _timer;

  _WordListState(
      this._participant, this._stimuli, this._fakeStimuli, this._onComplete) {
    _wordList.addAll(_stimuli.map((stimulus) => stimulus.name));
    _wordList.addAll(_fakeStimuli);
    _wordList.shuffle();
  }

  void decrementCountdown() {
    setState(() {
      _countdown--;

      if (_countdown == 0) {
        _started = true;
        _stopwatch.start();
      } else {
        _timer = Timer(SECOND, decrementCountdown);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    if (_timer != null && _timer.isActive) _timer.cancel();
    if (_stopwatch != null && _stopwatch.isRunning) _stopwatch.stop();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if (_participant.stageComplete) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Study Completed",
            style: theme.textTheme.headline,
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(
            "Thank you for participating!"
            " Please wait quietely while others finish",
            style: theme.textTheme.subhead,
            textAlign: TextAlign.center,
          )
        ],
      );
    }

    if (!_started) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Instructions:",
            style: theme.textTheme.display2,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
            child: Text(
              "You will be shown several words once you click \"Start\"." +
                  " Do your best to check the ones saw ealier."
                      " This section is timed.",
              style: theme.textTheme.headline,
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            "Check which Latin names you saw earlier",
            style: theme.textTheme.title,
          ),
        ),
        Text(
          "Tap \"Done\" when done",
          style: theme.textTheme.subtitle,
        ),
        Flexible(
          child: ListView(
            children: <Widget>[
              for (final String word in _wordList) _buildRow(word)
            ],
          ),
        ),
        ButtonBar(
          children: <Widget>[
            RaisedButton(
              onPressed: () => setState(() => _submit()),
              child: Text("Submit"),
              color: theme.accentColor,
            ),
          ],
        ),
      ],
    );
  }

  void _submit() {
    _stopwatch.stop();

    num correct = 0;
    _stimuli.forEach((stimulus) {
      if (_chosen.contains(stimulus.name)) correct++;
    });

    _participant.percentCorrect = (correct / _stimuli.length);
    _participant.submitTime = _stopwatch.elapsedMilliseconds;
    _onComplete(_participant);
  }

  Widget _buildRow(String word) {
    return ListTile(
      title: Text(word),
      leading: Checkbox(
        value: _chosen.contains(word),
        onChanged: (newValue) =>
            setState(() => newValue ? _chosen.add(word) : _chosen.remove(word)),
      ),
    );
  }
}
