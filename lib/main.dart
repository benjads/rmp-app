import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rmp_app/model/experiment.dart';
import 'package:rmp_app/model/participant.dart';
import 'package:rmp_app/repo/experiment_repo.dart';
import 'package:rmp_app/repo/participant_repo.dart';
import 'package:rmp_app/view/experimenter_view.dart';
import 'package:rmp_app/view/stimulus_view.dart';

import 'model/stimulus.dart';

const bool EXPERIMENTER_INSTALL = false;

Participant _participant;

void main() => runApp(RMPApp());

class RMPApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RMP Study',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: getLaunchPage(),
    );
  }

  Widget getLaunchPage() {
    if (EXPERIMENTER_INSTALL) return ExperimenterView();

    return StreamBuilder<Participant>(
        stream: _participant == null
            ? ParticipantRepo.addParticipant().asStream()
            : Future.value(_participant).asStream(),
        builder: (context, participantSnapshot) {
          if (!participantSnapshot.hasData) return CircularProgressIndicator();

          _participant = participantSnapshot.data;

          return StreamBuilder<DocumentSnapshot>(
            stream: ExperimentRepo.getExperimentStream(),
            builder: (context, experimentSnapshot) {
              if (!experimentSnapshot.hasData)
                return CircularProgressIndicator();

              if (experimentSnapshot.data.data == null) {
                ExperimentRepo.createExperiment();
                return CircularProgressIndicator();
              }

              final Experiment experiment =
                  Experiment.fromSnapshot(experimentSnapshot.data);
              switch (experiment.state) {
                case ExperimentState.TRAIN:
                  return StimulusView(Stimulus.stimuli, reportComplete);
                  break;
                case ExperimentState.DISTRACT:
                  return TestView();
                  break;
                case ExperimentState.TEST:
                  return TestView();
                  break;
                case ExperimentState.WAIT:
                  return TestView();
                  break;
                default:
                  return TestView();
              }
            },
          );
        });
  }

  void reportComplete() {}
}

class TestView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Text("Test")],
        ),
      ),
    );
  }
}
