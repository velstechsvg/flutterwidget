import 'dart:ui';
import 'package:flutter/material.dart';

import '../resources/app_colors.dart';

class SimpleShadow extends StatelessWidget {
  final Widget child;
  final double opacity;
  final double sigma;
  final Color? color;
  final Offset offset;

  SimpleShadow({
    required this.child,
    this.opacity = 0.1,
    this.sigma = 4,
    this.color = Colors.black,
    this.offset = const Offset(0, 4),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Transform.translate(
          offset: offset,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaY: sigma, sigmaX: sigma, tileMode: TileMode.decal),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.transparent,
                  width: 0,
                ),
              ),
              child: Opacity(
                opacity: opacity,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(color ?? AppColors.black, BlendMode.srcATop),
                  child: child,
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}