class HardSetJudge {
  const HardSetJudge();

  bool? isHardSet(int? rir) {
    if (rir == null) {
      return null;
    }

    if (rir < 0) {
      throw ArgumentError.value(rir, 'rir');
    }

    return rir <= 4;
  }
}
