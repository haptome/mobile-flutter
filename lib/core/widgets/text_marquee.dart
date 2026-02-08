import 'package:flutter/material.dart';

class TextMarquee extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final double gap;

  const TextMarquee({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(seconds: 20),
    this.gap = 60,
  });

  @override
  State<TextMarquee> createState() => _TextMarqueeState();
}

class _TextMarqueeState extends State<TextMarquee>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final double _textWidth;

  @override
  void initState() {
    super.initState();

    _textWidth = _measureTextWidth(widget.text, widget.style);

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = _textWidth + widget.gap;

        return ClipRect(
          child: SizedBox(
            width: constraints.maxWidth,
            height: _textHeight(widget.style),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                final dx =
                    -(_controller.value * totalWidth);

                return Stack(
                  children: [
                    Positioned(
                      left: dx,
                      child: Text(widget.text, style: widget.style),
                    ),
                    Positioned(
                      left: dx + totalWidth,
                      child: Text(widget.text, style: widget.style),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  double _measureTextWidth(String text, TextStyle? style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.width;
  }

  double _textHeight(TextStyle? style) {
    final painter = TextPainter(
      text: TextSpan(text: 'A', style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.height;
  }
}
