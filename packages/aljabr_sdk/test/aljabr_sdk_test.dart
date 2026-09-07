import 'package:flutter_test/flutter_test.dart';
import 'package:aljabr_sdk/aljabr_sdk.dart';

void main() {
  test('AljabrSdk version metadata is valid', () {
    expect(AljabrSdk.version, isNotEmpty);
  });
}
