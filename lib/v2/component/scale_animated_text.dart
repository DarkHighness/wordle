import 'package:flutter/material.dart';

class ScaleAnimatedText extends StatefulWidget {
  final String text;
  final double scalingFactor;
  final TextStyle? textStyle;
  final Duration duration;

  const ScaleAnimatedText({
    Key? key,
    required this.text,
    required this.scalingFactor,
    this.textStyle,
    this.duration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  ScaleAnimatedTextState createState() => ScaleAnimatedTextState();
}

class ScaleAnimatedTextState extends State<ScaleAnimatedText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleIn, _scaleOut;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    _scaleIn = Tween<double>(begin: widget.scalingFactor, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _scaleOut = Tween<double>(begin: 1.0, end: widget.scalingFactor).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleIn.value != 1.0 ? _scaleIn : _scaleOut,
      child: Text(
        widget.text,
        style: widget.textStyle,
      ),
    );
  }
}
