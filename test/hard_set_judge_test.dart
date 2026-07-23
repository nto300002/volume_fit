import 'package:flutter_test/flutter_test.dart';
import 'package:volume_fit/src/features/workout/domain/hard_set_judge.dart';

void main() {
  group('HardSetJudge', () {
    test('returns true for RIR 0 through 4', () {
      const judge = HardSetJudge();

      for (var rir = 0; rir <= 4; rir += 1) {
        expect(judge.isHardSet(rir), isTrue, reason: 'RIR $rir');
      }
    });

    test('returns false for RIR 5 and higher', () {
      const judge = HardSetJudge();

      expect(judge.isHardSet(5), isFalse);
      expect(judge.isHardSet(10), isFalse);
    });

    test('returns null when RIR is unknown', () {
      const judge = HardSetJudge();

      expect(judge.isHardSet(null), isNull);
    });

    test('rejects negative RIR', () {
      const judge = HardSetJudge();

      expect(() => judge.isHardSet(-1), throwsArgumentError);
    });
  });
}
