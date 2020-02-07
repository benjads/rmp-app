class FirestorePaths {
  static const PATH_DATA = "data";

  static const DOC_EXPERIMENT = "experiment";

  static const DOC_DATA = "data";

  static const PARTICIPANTS_PATH = "participants";

  static const String experimentDocPath = "$PATH_DATA/$DOC_EXPERIMENT";

  static const String experimentDataDocPath =
      "$experimentDocPath/$PATH_DATA/$DOC_DATA";
}
