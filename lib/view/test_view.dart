import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rmp_app/model/participant.dart';
import 'package:rmp_app/model/stimulus.dart';

const num COUNTDOWN_SECS = 3;
const num TIMER_SECS = 120;
const Duration SECOND = const Duration(seconds: 1);

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
      appBar: AppBar(),
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
  final Participant _participant;
  final List<Stimulus> _stimuli;
  final List<String> _fakeStimuli;
  final Function _onComplete;

  final List<String> _wordList = [];
  final List<String> _chosen = [];

  bool _started = false, _showArrow = true;
  ScrollController _scrollController;
  num _countdown = -1;
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
        _scrollController = ScrollController();
        _scrollController.addListener(() {
          if (_scrollController.offset > 0 && _showArrow)
            setState(() {
              _showArrow = false;
            });
        });
      } else {
        _timer = Timer(SECOND, decrementCountdown);
      }
    });
  }

  @override
  void dispose() {
    if (_timer != null && _timer.isActive) _timer.cancel();
    super.dispose();
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
            style: theme.textTheme.headline5,
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(
            "Thank you for participating!"
            " Please wait quietely while others finish",
            style: theme.textTheme.subtitle1,
            textAlign: TextAlign.center,
          )
        ],
      );
    }

    if (!_started) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 20.0),
            child: Text(
              "You will be shown several words once you click \"Start\"." +
                  " Do your best to check the ones you saw ealier."
                      " You will have two minutes.",
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            "Check which Latin names you saw earlier",
            style: theme.textTheme.headline6,
            textAlign: TextAlign.center,
          ),
        ),
        Text(
          "Tap \"Done\" when complete",
          style: theme.textTheme.subtitle2,
          textAlign: TextAlign.center,
        ),
        Flexible(
          child: Scrollbar(
            child: ListView(
              children: <Widget>[
                for (final String word in _wordList) _buildRow(word)
              ],
              controller: _scrollController,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TimerDisplay(submit, _participant),
              _showArrow ? Icon(Icons.arrow_downward) : Container(),
              ButtonBar(
                children: <Widget>[
                  RaisedButton(
                    onPressed: () => setState(() => submit()),
                    child: Text("Submit"),
                    color: theme.accentColor,
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void submit() {
    num correct = 0;
    _stimuli.forEach((stimulus) {
      if (_chosen.contains(stimulus.name)) correct++;
    });

    _participant.percentCorrect = (correct / _stimuli.length);

    setState(() {
      _onComplete(_participant);
    });
  }

  Widget _buildRow(String word) {
    return GestureDetector(
      onTap: () => toggleOption(word),
      child: ListTile(
        title: Text(
          word,
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        leading: Checkbox(
          value: _chosen.contains(word),
          onChanged: (newValue) => toggleOption(word),
        ),
      ),
    );
  }

  void toggleOption(String word) {
    setState(() =>
        _chosen.contains(word) ? _chosen.remove(word) : _chosen.add(word));
  }
}

class TimerDisplay extends StatefulWidget {
  final Function _timerEnd;
  final Participant _participant;

  TimerDisplay(this._timerEnd, this._participant);

  @override
  State<StatefulWidget> createState() =>
      _TimerDisplayState(_timerEnd, _participant);
}

class _TimerDisplayState extends State<TimerDisplay> {
  final Function _timerEnd;
  final Participant _participant;
  Timer _timer;

  _TimerDisplayState(this._timerEnd, this._participant);

  @override
  void initState() {
    super.initState();
    _timer = _timer = Timer(SECOND, decrementTimer);
  }

  @override
  void dispose() {
    if (_timer != null && _timer.isActive) _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Text(
      (TIMER_SECS - _participant.submitTime).toString(),
      style: theme.textTheme.headline4,
    );
  }

  void decrementTimer() {
    _participant.submitTime++;
    if (_participant.submitTime >= TIMER_SECS) _timerEnd();

    setState(() {
      _timer = Timer(SECOND, decrementTimer);
    });
  }
}
