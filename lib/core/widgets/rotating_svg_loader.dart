import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class RotatingSvgLoader extends StatefulWidget {
  const RotatingSvgLoader({super.key});

  @override
  State<RotatingSvgLoader> createState() => _RotatingSvgLoaderState();
}

class _RotatingSvgLoaderState extends State<RotatingSvgLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2925),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: SvgPicture.asset(
        'assets/icons/loader.svg',
        width: 48,
        height: 48,
      ),
    );
  }
}
