import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rmp_app/game/game.dart';
import 'package:rmp_app/model/experiment.dart';
import 'package:rmp_app/model/participant.dart';
import 'package:rmp_app/repo/experiment_repo.dart';
import 'package:rmp_app/repo/participant_repo.dart';
import 'package:rmp_app/view/distract_view.dart';
import 'package:rmp_app/view/experimenter_view.dart';
import 'package:rmp_app/view/stimulus_view.dart';
import 'package:rmp_app/view/survey_view.dart';
import 'package:rmp_app/view/test_view.dart';
import 'package:rmp_app/view/wait_view.dart';

import 'model/stimulus.dart';

Participant _participant;
BoxGame _game;

class RMPApp extends StatelessWidget {
  final bool experimenterApp;

  RMPApp(this.experimenterApp);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MaterialApp(
      title: experimenterApp ? 'Latinmem (Experimenter)' : 'Latinmem',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: getLaunchPage(context),
    );
  }

  Widget getLaunchPage(BuildContext context) {
    if (experimenterApp) return ExperimenterView();

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
      body: Center(
        child: Image(
          image: AssetImage("graphics/latinmem_logo.png"),
          height: 180.0,
        ),
      ),
    );
  }

  Future<DocumentSnapshot> loadData() async {
    await BoxGame.preload();
    _game = BoxGame();
    
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
  bool stateLock = false;

  _ParticipantAppState(this.experimentDoc);

  @override
  void initState() {
    super.initState();

    _state = Experiment.fromSnapshot(experimentDoc).state;

    if (_state == ExperimentState.RESET) stateLock = true;

    _experimentSub = ExperimentRepo.getExperimentStream().listen((snapshot) {
      final Experiment experiment = Experiment.fromSnapshot(snapshot);

      if (experiment.state == ExperimentState.RESET && !stateLock) {
        _participant = null;
        Navigator.of(context).pushReplacement(
            new MaterialPageRoute(builder: (context) => LaunchView()));
      } else {
        setState(() {
          stateLock = false;
          _participant.stageComplete = false;
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
      case ExperimentState.SURVEY:
        return SurveyView(_participant, reportComplete);
      case ExperimentState.TRAIN:
        return StimulusView(_participant, Stimulus.stimuli, reportComplete);
        break;
      case ExperimentState.DISTRACT:
        return DistractView(_game);
        break;
      case ExperimentState.TEST:
        return TestView(_participant, Stimulus.stimuli, Stimulus.fakeStimuli,
            reportComplete);
        break;
      case ExperimentState.WAIT:
      default:
        return WaitView();
        break;
    }
  }

  void reportComplete(Participant participant) {
    participant.stageComplete = true;
    ParticipantRepo.updateParticipant(participant);
  }
}