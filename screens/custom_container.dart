import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  const CustomContainer(
      {
        Key? key,
        @required this.body,
        this.padding,
        this.margin,
        this.onTap,
        this.color,
        this.enableLoad = false,
        this.isSmallCenterLoader = false,
        this.decoration
      }
  ) : super(key: key);

  final Widget? body;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Decoration? decoration;
  final Function? onTap;
  final bool?  enableLoad ;
  final bool? isSmallCenterLoader;
  final Color? color;



  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        padding: padding != null ? padding : EdgeInsets.zero,
        margin: margin != null ? margin : EdgeInsets.zero,
        decoration: decoration ?? (color != null ? BoxDecoration(color: color) : null),
        child: body,
      ),
    );
  }
}
