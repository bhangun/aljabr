import 'package:flutter/material.dart';

class PermissionTile extends StatelessWidget {
  final String resource;
  final bool isAllowed;

  const PermissionTile({
    super.key,
    required this.resource,
    required this.isAllowed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        isAllowed ? Icons.check_circle : Icons.cancel,
        color: isAllowed ? Colors.green : Colors.red,
        size: 18,
      ),
      title: Text(
        resource,
        style: const TextStyle(fontSize: 13, color: Colors.black87),
      ),
      trailing: Text(
        isAllowed ? 'Allowed' : 'Denied',
        style: TextStyle(
          fontSize: 12,
          color: isAllowed ? Colors.green : Colors.red,
          fontWeight: FontWeight.w500,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      dense: true,
    );
  }
}
