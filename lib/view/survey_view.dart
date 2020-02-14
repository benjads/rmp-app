import 'package:rmp_app/model/participant.dart';
import 'package:flutter/material.dart';

class SurveyView extends StatelessWidget {
  final Participant _participant;
  final Function _onComplete;

  SurveyView(this._participant, this._onComplete);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            child: QuestionContainer(_participant, _onComplete),
          ),
        ),
      ),
    );
  }
}

class QuestionContainer extends StatefulWidget {
  final Participant _participant;
  final Function _onComplete;

  QuestionContainer(this._participant, this._onComplete);

  @override
  State<StatefulWidget> createState() =>
      _QuestionContainerState(_participant, _onComplete);
}

class _QuestionContainerState extends State<QuestionContainer> {
  final Participant _participant;
  final Function _onComplete;
  bool _complete = false;

  _QuestionContainerState(this._participant, this._onComplete);

  @override
  void initState() {
    super.initState();

    for (final SurveyQuestion question in SurveyQuestion.values)
      if (_participant.survey[question.toString()] == null)
        return;

    _complete = true;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if (_participant.stageComplete) {
      return Text("Submitted. Please wait.",
      style: theme.textTheme.headline,);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          "Please answer the following questions",
          style: theme.textTheme.title,
        ),
        Text(
          "Tap \"Done\" when complete",
          style: theme.textTheme.subtitle,
        ),
        for (final SurveyQuestion question in SurveyQuestion.values)
          QuestionWidget(question, _participant, () {
            checkCompletion();
          }),
        ButtonBar(
          children: <Widget>[
            RaisedButton(
              onPressed: _complete
                  ? () => setState(() => _onComplete(_participant))
                  : null,
              child: Text("Done"),
              color: theme.accentColor,
              disabledColor: theme.disabledColor,
            ),
          ],
        ),
      ],
    );
  }

  void checkCompletion() {
    for (final SurveyQuestion question in SurveyQuestion.values)
      if (_participant.survey[question.toString()] == null) return;

    setState(() {
      _complete = true;
    });
  }
}

class QuestionWidget extends StatefulWidget {
  final SurveyQuestion _question;
  final Participant _participant;
  final VoidCallback _callback;

  QuestionWidget(this._question, this._participant, this._callback);

  @override
  State<StatefulWidget> createState() =>
      _QuestionWidgetState(_question, _participant, _callback);
}

class _QuestionWidgetState extends State<QuestionWidget> {
  final SurveyQuestion _question;
  final Participant _participant;
  final VoidCallback _callback;

  _QuestionWidgetState(this._question, this._participant, this._callback);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      elevation: 3.0,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                _question.questionText,
                style: theme.textTheme.subtitle,
              ),
            ),
            for (final String choice in _question.radioOptions)
              ListTile(
                title: Text(choice),
                leading: Radio(
                  value: choice,
                  groupValue: _participant.survey[_question.toString()],
                  onChanged: (chosen) {
                    setState(() {
                      _participant.survey[_question.toString()] = chosen;
                      _callback();
                    });
                  },
                ),
              )
          ],
        ),
      ),
    );
  }
}
