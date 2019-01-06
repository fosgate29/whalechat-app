import 'package:flutter/material.dart';

class FlexibleScrollView {
  /// A rather convoluted tree to achieve SingleChildScrollView that
  /// "just works" with a Column body, based on
  /// https://docs.flutter.io/flutter/widgets/SingleChildScrollView-class.html
  static build({
    @required BuildContext context,
    @required Widget child,
    EdgeInsets padding = const EdgeInsets.fromLTRB(24, 24, 24, 8),
  }) {
    return LayoutBuilder(builder: (_, constraints) => SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: IntrinsicHeight(
          child: Padding(
            padding: padding,
            child: child,
          )
        )
      )
    ));
  }
}
