import 'dart:async';

import 'package:crossfire/crossfire.dart';
import 'package:rmp_app/model/stimulus.dart';
import 'package:rmp_app/platform/platform_provider.dart' as PlatformProvider;
import 'package:flutter/foundation.dart';
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

Participant _participant;
BoxGame _game;
Firebase _firebase;
ExperimentRepo _experimentRepo;
ParticipantRepo _participantRepo;

bool _experimenterApp;

class RMPApp extends StatelessWidget {
  RMPApp(bool experimenterApp) {
    _experimenterApp = experimenterApp;
    debugPrint(experimenterApp
        ? "Initializing RMP App (Experimenter)"
        : "Initializing RMP App (Participant)");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _experimenterApp ? 'Latinmem (Experimenter)' : 'Latinmem',
      theme: ThemeData(
        primaryColor: Color.fromRGBO(43, 46, 74, 1.0),
        accentColor: Color.fromRGBO(144, 55, 73, 1.0),
        highlightColor: Color.fromRGBO(232, 69, 69, 1.0),
      ),
      home: LaunchView(),
    );
  }

  static ExperimentRepo get experimentRepo => _experimentRepo;

  static ParticipantRepo get participantRepo => _participantRepo;
}

class LaunchView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (_experimenterApp) {
      loadCommonData().whenComplete(() => Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => ExperimenterView())));
    } else {
      loadParticipantData(context).then((experiment) => Navigator.of(context)
          .pushReplacement(new MaterialPageRoute(
              builder: (context) => ParticipantApp(experiment))));
    }

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

  Future<void> loadCommonData() async {
    FirebaseConfiguration configuration = FirebaseConfiguration(
      apiKey: "AIzaSyB9GVjzEh69CsP4GcgIWdNSwwrs14yBtso",
      databaseUrl: "https://rmp-study.firebaseio.com",
      storageBucket: "rmp-study.appspot.com",
      projectId: "rmp-study",
      iosGoogleAppId: "1:1045382126903:ios:27bafcf2339358d6bb0eb2",
      androidGoogleAppId: "1:1045382126903:android:1b04a6b51f9edf18bb0eb2",
    );

    if (!kIsWeb) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }

    _firebase = PlatformProvider.getFirebase();

    await _firebase.init(configuration);

    _participantRepo = ParticipantRepo(_firebase);
    await _participantRepo.initialize();
    _experimentRepo = ExperimentRepo(_firebase);
    await _experimentRepo.initialize();
  }

  Future<Experiment> loadParticipantData(BuildContext context) async {
    await loadCommonData();

    await BoxGame.preload();
    _game = BoxGame();

    await Stimulus.cache(context);

    final Participant participant = await _participantRepo.addParticipant();
    _participant = participant;

    final Experiment experiment = await _experimentRepo.getExperiment();
    if (experiment == null)
      return await _experimentRepo.createExperiment();
    else
      return experiment;
  }
}

class ParticipantApp extends StatefulWidget {
  final Experiment experiment;

  ParticipantApp(this.experiment);

  @override
  State<StatefulWidget> createState() => _ParticipantAppState(experiment);
}

class _ParticipantAppState extends State<ParticipantApp> {
  final Experiment experiment;

  ExperimentState _state;
  StreamSubscription _experimentSub;
  bool stateLock = false;

  _ParticipantAppState(this.experiment);

  @override
  void initState() {
    super.initState();

    _state = experiment.state;

    if (_state == ExperimentState.RESET) stateLock = true;

    _experimentSub = _experimentRepo.getExperimentStream().listen((snapshot) {
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
    _participantRepo.updateParticipant(participant);
  }
}
