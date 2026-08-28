import '../extensions/contribution.dart';

class CapabilityContribution implements OwnedContribution {
  @override
  final String id;

  @override
  final String ownerId;

  final String description;
  final Map<String, Object?> metadata;

  const CapabilityContribution({
    required this.id,
    required this.ownerId,
    this.description = '',
    this.metadata = const {},
  });
}
