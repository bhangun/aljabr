import 'package:flutter/material.dart';

class RadioOption<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T?> onChanged;
  final String label;

  const RadioOption({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<T>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      title: Text(
        label,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      dense: true,
      visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
      activeColor: Colors.blue,
    );
  }
}
