import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'edition.dart';

class LicenseInfo {
  final AljabrEdition edition;
  final String? organization;
  final String? licenseKey;
  final DateTime? expiresAt;
  final Set<String> activeFeatures;

  const LicenseInfo({
    this.edition = AljabrEdition.community,
    this.organization,
    this.licenseKey,
    this.expiresAt,
    this.activeFeatures = const {},
  });

  bool hasFeature(String feature) => activeFeatures.contains(feature);

  LicenseInfo copyWith({
    AljabrEdition? edition,
    String? organization,
    String? licenseKey,
    DateTime? expiresAt,
    Set<String>? activeFeatures,
  }) {
    return LicenseInfo(
      edition: edition ?? this.edition,
      organization: organization ?? this.organization,
      licenseKey: licenseKey ?? this.licenseKey,
      expiresAt: expiresAt ?? this.expiresAt,
      activeFeatures: activeFeatures ?? this.activeFeatures,
    );
  }
}

class LicenseNotifier extends Notifier<LicenseInfo> {
  @override
  LicenseInfo build() {
    return const LicenseInfo(
      edition: AljabrEdition.pro,
      activeFeatures: {
        'aljabr.feature.governance',
        'aljabr.feature.audit',
        'aljabr.feature.analytics',
        'aljabr.feature.collaboration',
        'aljabr.feature.admin',
      },
    );
  }

  void switchEdition(AljabrEdition edition) {
    state = state.copyWith(
      edition: edition,
      activeFeatures: edition.isProOrHigher
          ? {
              'aljabr.feature.governance',
              'aljabr.feature.audit',
              'aljabr.feature.analytics',
              'aljabr.feature.collaboration',
              'aljabr.feature.admin',
            }
          : {},
    );
  }
}

final licenseProvider = NotifierProvider<LicenseNotifier, LicenseInfo>(
  () => LicenseNotifier(),
);
