import 'package:crossfire/crossfire.dart';
import 'package:rmp_app/repo/common.dart';
import 'package:rmp_app/model/experiment.dart';

class ExperimentRepo {

  final Firebase _firebase;
  FirebaseDocumentReference _experimentRef;

  ExperimentRepo(this._firebase);

  Future<void> initialize() async {
    _experimentRef = await _firebase.getDocument(FirestorePaths.experimentDocPath);
  }

  Future<Experiment> getExperiment() async {
    final FirebaseDocument doc = await _experimentRef.document;
    if (doc == null)
      return null;

    return Experiment.fromSnapshot(doc);
  }

  Stream<FirebaseDocument> getExperimentStream() {
    return _experimentRef.onSnapshot;
  }

  Future<Experiment> createExperiment() async {
    await _experimentRef.setData(Experiment.defaultMap);
    final FirebaseDocument doc =  await _experimentRef.document;
    return Experiment.fromSnapshot(doc);
  }

  Future<void> updateExperiment(Experiment experiment) async {
    _experimentRef.setData(experiment.map);
  }
}
