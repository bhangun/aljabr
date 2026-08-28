import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

class AddMenuButton extends StatelessWidget {
  const AddMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(6),
      child: const Padding(
        padding: EdgeInsets.all(4),
        child: Icon(
          Icons.add,
          size: 18,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}
