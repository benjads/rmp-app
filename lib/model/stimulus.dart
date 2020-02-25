import 'package:flutter/material.dart';

class Stimulus {
  final String standardPath, mnemonicPath;
  AssetImage _standardImage, _mnemonicImage;
  final String name, mnemonicName;

  Stimulus(
      this.standardPath, this.mnemonicPath, this.name, this.mnemonicName);

  static final List<Stimulus> stimuli = [
    Stimulus(
        "graphics/stimuli/melospiza_lincolnii_baseline.jpg",
        "graphics//stimuli/melospiza_lincolnii_mnemonic.jpg",
        "Melospiza lincolnii",
        "Melon–pizza, Lincoln–penny",
    ),
    Stimulus(
      "graphics/stimuli/seterna_hirundo_baseline.jpg",
      "graphics//stimuli/seterna_hirundo_mnemonic.jpg",
      "Seterna hirundo",
      "Saturn hairdo",
    ),
    Stimulus(
      "graphics/stimuli/vireo_gilvus_baseline.jpg",
      "graphics//stimuli/vireo_gilvus_mnemonic.jpg",
      "Vireo gilvus",
      "Video fishgils",
    ),
  ];

  ImageProvider get standardImage => _standardImage;

  ImageProvider get mnemonicImage => _mnemonicImage;
  
  static Future<void> cache(BuildContext context) async {
    for (final Stimulus stimulus in stimuli) {
      stimulus._standardImage = AssetImage(stimulus.standardPath);
      stimulus._mnemonicImage = AssetImage(stimulus.mnemonicPath);
      await precacheImage(stimulus._standardImage, context);
      await precacheImage(stimulus._mnemonicImage, context);
    }
  }

  static const List<String> fakeStimuli = [
    "fake1",
    "fake2",
    "fake3",
    "fake4",
    "fake5",
    "fake6",
    "fake7",
    "fake8",
    "fake9",
    "fake10",
    "fake11",
    "fake12",
    "fake13",
    "fake14",
    "fake15",
    "fake16",
    "fake17",
    "fake18",
    "fake19",
    "fake20",
  ];
}
