import 'package:flutter/material.dart';

class NavigateIntent extends Intent {
  final int direction;
  const NavigateIntent(this.direction);
}

class SendMessageIntent extends Intent {}
