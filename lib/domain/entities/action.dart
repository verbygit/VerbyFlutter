enum Action {
  ERROR(-1),
  CHECKIN(0),
  CHECKOUT(1),
  PAUSEIN(2),
  PAUSEOUT(3);

  final int action;

  const Action(this.action);

  int getActionValue() => action;

  static Action getAction(int action) {
    return Action.values.firstWhere(
          (act) => act.action == action,
      orElse: () => Action.ERROR,
    );
  }
}
