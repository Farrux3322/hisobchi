import 'dart:async';

import 'package:flutter/material.dart';

class Debounce {
  Timer? _timer;

  void run(VoidCallback action, [int milliseconds = 500]) {
    if (_timer != null) _timer!.cancel();

    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
