abstract interface class OwnedContribution {
  /// Globally unique contribution ID.
  String get id;

  /// Module/plugin responsible for this contribution.
  String get ownerId;
}

abstract interface class OwnerCleanup {
  void unregisterAllForOwner(String ownerId);
}
