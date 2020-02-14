import 'package:rmp_app/model/participant.dart';
import 'package:rmp_app/repo/participant_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rmp_app/model/experiment.dart';
import 'package:rmp_app/repo/experiment_repo.dart';
import 'package:rmp_app/util.dart';

class ExperimenterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Card(
            margin: EdgeInsets.all(12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: StreamBuilder<DocumentSnapshot>(
              stream: ExperimentRepo.getExperimentStream(),
              builder: (context, experimentSnapshot) {
                if (!experimentSnapshot.hasData)
                  return CircularProgressIndicator();

                if (experimentSnapshot.data == null) {
                  ExperimentRepo.createExperiment();
                  return LinearProgressIndicator();
                }

                final Experiment experiment =
                    Experiment.fromSnapshot(experimentSnapshot.data);

                return StreamBuilder<QuerySnapshot>(
                  stream: ParticipantRepo.getParticipants(),
                  builder: (context, participantsSnapshot) {
                    if (!participantsSnapshot.hasData)
                      return CircularProgressIndicator();

                    final List<Participant> participants = [];
                    participantsSnapshot.data.documents
                        .forEach((participantDoc) {
                      participants
                          .add(Participant.fromSnapshot(participantDoc));
                    });

                    return Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            "Experimenter Controls",
                            style: theme.textTheme.title,
                          ),
                          ..._buildParticipantData(participants),
                          _buildDataRow(
                            Icons.extension,
                            "Phase",
                            Text(
                              RMPUtil.formatEnum(experiment.state),
                            ),
                          ),
                          experiment.state == ExperimentState.RESET
                              ? Container()
                              : ButtonBar(
                                  children: <Widget>[
                                    RaisedButton(
                                      onPressed: () => _promptReset(
                                          context, experiment, participants),
                                      child: Text("Reset"),
                                      color: theme.colorScheme.error,
                                    ),
                                    RaisedButton(
                                      onPressed: () => _changeState(experiment,
                                          experiment.state.previous, participants),
                                      child: Text("Previous Phase"),
                                      color: theme.accentColor,
                                    ),
                                    RaisedButton(
                                      onPressed: () => _changeState(experiment,
                                          experiment.state.next, participants),
                                      child: Text("Next Phase"),
                                      color: theme.accentColor,
                                    ),
                                  ],
                                )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildParticipantData(List<Participant> participants) {
    final num count = participants.length;
    num complete = 0;
    Map<Condition, num> conditions = {};

    Condition.values.forEach((condition) => conditions[condition] = 0);

    participants.forEach((participant) {
      conditions[participant.condition]++;
      if (participant.stageComplete) complete++;
    });

    final List<Widget> conditionsWidgets = [];
    for (Condition condition in conditions.keys) {
      final String name = RMPUtil.formatEnum(condition);
      conditionsWidgets.add(Text("$name - ${conditions[condition]}"));
    }

    return [
      _buildDataRow(Icons.person, "Participants", Text(count.toString())),
      _buildDataRow(Icons.done, "Participants Complete",
          count == 0 ? Text("N/A") : Text("$complete (${RMPUtil.percent(complete, count)})")),
      _buildDataRow(
        Icons.call_split,
        "Conditions",
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: conditionsWidgets),
      ),
    ];
  }

  Widget _buildDataRow(IconData icon, String title, Widget data) {
    return MergeSemantics(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 18.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 5.0),
                    child: Icon(icon),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              width: 90.0,
              child: data,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _promptReset(BuildContext context, Experiment experiment,
      List<Participant> participants) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Reset"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("All participants and data will be lost!"),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Reset'),
              onPressed: () {
                _changeState(experiment, ExperimentState.RESET, participants);
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _changeState(Experiment experiment, ExperimentState state,
      List<Participant> participants) async {
    final WriteBatch batch = Firestore.instance.batch();
    assert(participants != null);

    if (state == ExperimentState.RESET) {
      ParticipantRepo.clearParticipants(participants, batch);

      experiment.state = state;
      batch.updateData(experiment.reference, experiment.map);
      batch.commit();

      Future.delayed(const Duration(seconds: 2), () {
        experiment.state = ExperimentState.WAIT;
        ExperimentRepo.updateExperiment(experiment);
      });
    } else {
      experiment.state = state;
      ExperimentRepo.updateExperiment(experiment);

      participants.forEach((participant) {
        participant.stageComplete = false;
        participant.reference.updateData(participant.map);
      });

      batch.commit();
    }
  }
}
