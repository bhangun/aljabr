enum AljabrEdition {
  community,
  pro,
  enterprise;

  bool get isProOrHigher => this == AljabrEdition.pro || this == AljabrEdition.enterprise;
  bool get isEnterprise => this == AljabrEdition.enterprise;

  String get displayName {
    switch (this) {
      case AljabrEdition.community:
        return 'Community';
      case AljabrEdition.pro:
        return 'Professional';
      case AljabrEdition.enterprise:
        return 'Enterprise';
    }
  }
}
