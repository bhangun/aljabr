import 'package:flutter_test/flutter_test.dart';
import 'package:aljabr_platform/aljabr_platform.dart';

void main() {
  test('PlatformEnvironment and BackendBinaryInfo model tests', () {
    const env = PlatformEnvironment(
      os: 'macos',
      arch: 'aarch64',
      userHome: '/Users/bhangun',
      appDataDir: '/Users/bhangun/.gemini/antigravity',
    );
    expect(env.os, 'macos');
    expect(env.arch, 'aarch64');
  });
}
