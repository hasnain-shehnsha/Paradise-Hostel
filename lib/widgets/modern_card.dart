import 'package:flutter/material.dart';

class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double elevation;
  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.elevation = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      color: color ?? Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(18.0),
        child: child,
      ),
    );
  }
}
