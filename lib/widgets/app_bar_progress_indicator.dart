import 'package:flutter/material.dart';

import 'package:chummer_chummer/theme/sizes.dart';

class AppBarProgressIndicator extends PreferredSize {
  AppBarProgressIndicator({Key? key})
      : super(key: key, preferredSize: const Size.fromHeight(Sizing.xs), child: Container()); // super requires child but we ignore it in build

  @override
  Widget build(BuildContext context) => LinearProgressIndicator(
        minHeight: Sizing.xs,
        color: Theme.of(context).colorScheme.secondary,
        backgroundColor: Theme.of(context).colorScheme.surface,
      );
}
