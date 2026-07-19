import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_environment.dart';

typedef Clock = DateTime Function();

final appEnvironmentProvider = Provider<AppEnvironmentConfig>(
  (ref) => AppEnvironmentConfig.current(),
);

final clockProvider = Provider<Clock>((ref) => DateTime.now);
