import 'package:flutter/material.dart';

class GradientMask extends StatelessWidget {
  final Widget child;

  GradientMask(this.child);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
              colors: <Color>[
                Color(0xffF5D020),
                Color(0xffF53803),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds),
        child: child);
  }
}
