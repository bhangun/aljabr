import 'package:flutter/widgets.dart';

class SettingsContribution {
  final String id;
  final String title;
  final IconData? icon;
  final String? category;
  final int order;
  final Widget Function(BuildContext context) builder;

  const SettingsContribution({
    required this.id,
    required this.title,
    this.icon,
    this.category,
    this.order = 0,
    required this.builder,
  });
}
