import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rmp_app/model/experiment.dart';
import 'package:rmp_app/model/experiment_data.dart';
import 'package:rmp_app/repo/experiment_data_repo.dart';
import 'package:rmp_app/repo/experiment_repo.dart';

class ExperimenterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder<DocumentSnapshot>(
              stream: ExperimentRepo.getExperimentStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return LinearProgressIndicator();

                if (snapshot.data == null) {
                  ExperimentRepo.createExperiment();
                  return LinearProgressIndicator();
                }

                return Text(
                  Experiment.fromSnapshot(snapshot.data).state.toString(),
                  style: theme.textTheme.subhead,
                );
              },
            ),
            StreamBuilder<DocumentSnapshot>(
              stream: ExperimentDataRepo.getExperimentDataStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return LinearProgressIndicator();

                if (snapshot.data.data == null) {
                  ExperimentDataRepo.createExperimentData();
                  return LinearProgressIndicator();
                }

                return Text(
                  ExperimentData.fromSnapshot(snapshot.data)
                      .participantCount
                      .toString(),
                  style: theme.textTheme.subhead,
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
