import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rmp_app/model/experiment_data.dart';
import 'package:rmp_app/repo/common.dart';

class ExperimentDataRepo {
  static final Firestore _firestore = Firestore.instance;

  static Stream<DocumentSnapshot> getExperimentDataStream() {
    return _firestore.document(FirestorePaths.experimentDataDocPath).snapshots();
  }

  static void createExperimentData() {
    final DocumentReference docRef =
    _firestore.document(FirestorePaths.experimentDataDocPath);
    final ExperimentData data = ExperimentData(docRef);
    docRef.setData(data.map);
  }
}
