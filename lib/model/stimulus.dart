class Stimulus {

  final String path;
  final String name;

  const Stimulus(this.path, this.name);

  static const List<Stimulus> stimuli = [
    const Stimulus("graphics/rainbow_trout.jpeg", "Oncorhynchus mykiss")
  ];
}