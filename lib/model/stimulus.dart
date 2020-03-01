import 'package:flutter/material.dart';

class Stimulus {
  final String standardPath, mnemonicPath;
  AssetImage _standardImage, _mnemonicImage;
  final String name, mnemonicName;

  Stimulus(this.standardPath, this.mnemonicPath, this.name, this.mnemonicName);

  static final List<Stimulus> stimuli = [
    Stimulus(
      "graphics/stimuli/bombycilla_garrulus_baseline.jpg",
      "graphics/stimuli/bombycilla_garrulus_mnemonic.jpg",
      "Bombycilla garrulus",
      "Bomb-cell guard",
    ),
    Stimulus(
      "graphics/stimuli/chordeiles_minor_baseline.jpg",
      "graphics/stimuli/chordeiles_minor_mnemonic.jpg",
      "Chordeiles minor",
      "Cord-deli miner",
    ),
    Stimulus(
      "graphics/stimuli/circus_cyaneus_baseline.jpg",
      "graphics/stimuli/circus_cyaneus_mnemonic.jpg",
      "Circus cyaneus",
      "Circus insane",
    ),
    Stimulus(
      "graphics/stimuli/columba_livia_baseline.jpg",
      "graphics/stimuli/columba_livia_mnemonic.jpg",
      "Columba livia",
      "Columbia live",
    ),
    Stimulus(
      "graphics/stimuli/melospiza_lincolnii_baseline.jpg",
      "graphics/stimuli/melospiza_lincolnii_mnemonic.jpg",
      "Melospiza lincolnii",
      "Melon–pizza, Lincoln–penny",
    ),
    Stimulus(
      "graphics/stimuli/seterna_hirundo_baseline.jpg",
      "graphics/stimuli/seterna_hirundo_mnemonic.jpg",
      "Seterna hirundo",
      "Saturn hairdo",
    ),
    Stimulus(
      "graphics/stimuli/sitta_canadensis_baseline.jpg",
      "graphics/stimuli/sitta_canadensis_mnemonic.jpg",
      "Sitta canadensis",
      "Sit Canada",
    ),
    Stimulus(
      "graphics/stimuli/stellula_calliope_baseline.jpg",
      "graphics/stimuli/stellula_calliope_mnemonic.jpg",
      "Stellula calliope",
      "Stellar-hula cantaloupe",
    ),
    Stimulus(
      "graphics/stimuli/turdus_migratorius_baseline.jpg",
      "graphics/stimuli/turdus_migratorius_mnemonic.jpg",
      "Turdus migratorius",
      "Turd migration",
    ),
    Stimulus(
      "graphics/stimuli/vireo_gilvus_baseline.jpg",
      "graphics/stimuli/vireo_gilvus_mnemonic.jpg",
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
    "Aegolius funereus",
    "Aix sponsa",
    "Aythya valisineria",
    "Bonasa umbellus",
    "Buteo lagopus",
    "Calidris pusilla",
    "Ceryle alcyon",
    "Childonias niger",
    "Corvus corax",
    "Dendroica coronata",
    "Falco sparverius",
    "Zonotrichia leucophrys",
    "Wilsonia pusilla",
    "Troglodytes aedon",
    "Strix nebulosa",
    "Selasphorus rufus",
    "Regulus calendula",
    "Poecile refescens",
    "Oxyura jamaicensis",
    "Illadopsis cleaveri"
  ];
}
