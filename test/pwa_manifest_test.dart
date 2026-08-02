import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defines an installable Volume Fit web manifest', () async {
    final manifestFile = File('web/manifest.json');
    final manifest = jsonDecode(await manifestFile.readAsString())
        as Map<String, Object?>;

    expect(manifest['name'], 'Volume Fit');
    expect(manifest['short_name'], 'Volume Fit');
    expect(manifest['display'], 'standalone');
    expect(manifest['start_url'], '/');
    expect(manifest['theme_color'], '#0B57D0');
    expect(manifest['background_color'], '#F7F9FC');
    expect(manifest['description'], '筋トレ記録をAIへつなぐアプリ');

    final icons = manifest['icons'] as List<Object?>;
    expect(
      icons.whereType<Map<String, Object?>>().any(
        (icon) => icon['sizes'] == '192x192' && icon['purpose'] == 'any',
      ),
      isTrue,
    );
    expect(
      icons.whereType<Map<String, Object?>>().any(
        (icon) => icon['sizes'] == '512x512' && icon['purpose'] == 'maskable',
      ),
      isTrue,
    );
  });
}
