enum Perform {
  ERROR(-1),
  STEWARDING(0),
  MAINTENANCE(1),
  ROOMCONTROL(2),
  ROOMCLEANING(3),
  BURO(4);

  final int perform;

  const Perform(this.perform);

  int getPerformValue() => perform;

  static Perform getPerform(int perform) {
    return Perform.values.firstWhere(
      (act) => act.perform == perform,
      orElse: () => Perform.ERROR,
    );
  }
}
