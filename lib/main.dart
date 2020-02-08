import 'dart:async';

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
      home: getLaunchPage(context),
    );
  }

  Widget getLaunchPage(BuildContext context) {
    if (EXPERIMENTER_INSTALL) return ExperimenterView();

    return LaunchView();
  }
}

class LaunchView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    loadData().then((experimentSnapshot) => Navigator.of(context)
        .pushReplacement(new MaterialPageRoute(
            builder: (context) => ParticipantApp(experimentSnapshot))));

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: FlutterLogo()),
    );
  }

  Future<DocumentSnapshot> loadData() async {
    final Participant participant = await ParticipantRepo.addParticipant();

    _participant = participant;

    final DocumentSnapshot experimentDoc = await ExperimentRepo.getExperiment();

    if (experimentDoc.data == null)
      return await ExperimentRepo.createExperiment();
    else
      return experimentDoc;
  }
}

class ParticipantApp extends StatefulWidget {
  final DocumentSnapshot experimentDoc;

  ParticipantApp(this.experimentDoc);

  @override
  State<StatefulWidget> createState() => _ParticipantAppState(experimentDoc);
}

class _ParticipantAppState extends State<ParticipantApp> {
  final DocumentSnapshot experimentDoc;

  ExperimentState _state;
  StreamSubscription _experimentSub;

  _ParticipantAppState(this.experimentDoc);

  @override
  void initState() {
    super.initState();

    _state = Experiment.fromSnapshot(experimentDoc).state;

    _experimentSub = ExperimentRepo.getExperimentStream().listen((snapshot) {
      final Experiment experiment = Experiment.fromSnapshot(snapshot);

      if (experiment.state == ExperimentState.RESET) {
        _participant = null;
        Navigator.of(context).pushReplacement(
            new MaterialPageRoute(builder: (context) => LaunchView()));
      } else {
        setState(() {
          _state = experiment.state;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    _experimentSub.cancel();
  }

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case ExperimentState.TRAIN:
        return StimulusView(_participant, Stimulus.stimuli, reportComplete);
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
