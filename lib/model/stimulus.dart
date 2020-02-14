class Stimulus {
  final String standardPath, mnemonicPath;
  final String name, mnemonicName;

  const Stimulus(
      this.standardPath, this.mnemonicPath, this.name, this.mnemonicName);

  static const List<Stimulus> stimuli = [
    const Stimulus("graphics/rainbow_trout.jpg", "graphics/rainbow_trout.jpg",
        "Oncorhynchus mykiss", "Accordion Kiss"),
    const Stimulus(
        "graphics/circus_cyaneus_standard.jpg",
        "graphics/circus_cyaneus_mnemonic.jpg",
        "Circus Cyaneus",
        "Circus Insane")
  ];

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
    "fake21",
    "fake22",
    "fake23",
    "fake24",
  ];
}
