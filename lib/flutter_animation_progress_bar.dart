import 'package:flutter/animation.dart';
import 'package:flutter/widgets.dart';

String _defaultFormatValue(double value, int? fixed) {
  if (fixed != null) {
    return value.toStringAsFixed(fixed);
  } else {
    return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
  }
}

class FAProgressBar extends StatefulWidget {
  FAProgressBar({
    Key? key,
    this.currentValue = 0,
    this.maxValue = 100,
    this.size = 30,
    this.animatedDuration = const Duration(milliseconds: 300),
    this.direction = Axis.horizontal,
    this.verticalDirection = VerticalDirection.down,
    BorderRadiusGeometry? borderRadius,
    this.border,
    this.backgroundColor = const Color(0x00FFFFFF),
    this.progressColor = const Color(0xFFFA7268),
    this.changeColorValue,
    this.changeProgressColor = const Color(0xFF5F4B8B),
    this.formatValue = _defaultFormatValue,
    this.formatValueFixed,
    this.displayText,
    this.displayTextStyle =
        const TextStyle(color: const Color(0xFFFFFFFF), fontSize: 12),
    this.progressGradient
  })  : _borderRadius = borderRadius ?? BorderRadius.circular(8),
        super(key: key);
  final double currentValue;
  final double maxValue;
  final double size;
  final Duration animatedDuration;
  final Axis direction;
  final VerticalDirection verticalDirection;
  final BorderRadiusGeometry _borderRadius;
  final BoxBorder? border;
  final Color backgroundColor;
  final Color progressColor;
  final int? changeColorValue;
  final Color changeProgressColor;
  final String Function(double value, int? fixed) formatValue;
  final int? formatValueFixed;
  final String? displayText;
  final TextStyle displayTextStyle;
  final Gradient? progressGradient;

  @override
  _FAProgressBarState createState() => _FAProgressBarState();
}

class _FAProgressBarState extends State<FAProgressBar>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _controller;
  double _currentBegin = 0;
  double _currentEnd = 0;

  @override
  void initState() {
    _controller =
        AnimationController(duration: widget.animatedDuration, vsync: this);
    _animation = Tween<double>(begin: _currentBegin, end: _currentEnd)
        .animate(_controller);
    initValue();
    super.initState();
  }

  @override
  void didUpdateWidget(FAProgressBar old) {
    triggerAnimation();
    super.didUpdateWidget(old);
  }
  
  void initValue() {
    setState(() {
      _currentBegin = _animation.value;

      if (widget.currentValue == 0 || widget.maxValue == 0) {
        _currentEnd = 0;
      } else {
        _currentEnd = widget.currentValue / widget.maxValue;
      }

      _animation = Tween<double>(begin: _currentBegin, end: _currentEnd)
          .animate(_controller);
    });
    _controller.reset();
    _controller.duration = Duration.zero;
    _controller.forward();
  }

  void triggerAnimation() {
    setState(() {
      _currentBegin = _animation.value;

      if (widget.currentValue == 0 || widget.maxValue == 0) {
        _currentEnd = 0;
      } else {
        _currentEnd = widget.currentValue / widget.maxValue;
      }

      _animation = Tween<double>(begin: _currentBegin, end: _currentEnd)
          .animate(_controller);
    });
    _controller.reset();
    _controller.duration = widget.animatedDuration;
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) => AnimatedProgressBar(
        animation: _animation,
        widget: widget,
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class AnimatedProgressBar extends AnimatedWidget {
  AnimatedProgressBar({
    Key? key,
    required Animation<double> animation,
    required this.widget,
  }) : super(key: key, listenable: animation);

  final FAProgressBar widget;

  double transformValue(x, begin, end, before) {
    double y = (end * x - (begin - before)) * (1 / before);
    return y < 0 ? 0 : ((y > 1) ? 1 : y);
  }

  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    Color progressColor = widget.progressColor;

    if (widget.changeColorValue != null) {
      final _colorTween = ColorTween(
        begin: widget.progressColor,
        end: widget.changeProgressColor,
      );

      progressColor = _colorTween.transform(transformValue(
        animation.value,
        widget.changeColorValue,
        widget.maxValue,
        5,
      ))!;
    }

    List<Widget> progressWidgets = [];
    Widget progressWidget = Container(
      decoration: BoxDecoration(
        color: widget.progressGradient != null ? null : progressColor,
        gradient: widget.progressGradient,
        borderRadius: widget._borderRadius,
        border: widget.border,
      ),
    );
    progressWidgets.add(progressWidget);

    if (widget.displayText != null) {
      Widget textProgress = Container(
        alignment: widget.direction == Axis.horizontal
            ? FractionalOffset(0.95, 0.5)
            : (widget.verticalDirection == VerticalDirection.up
                ? FractionalOffset(0.5, 0.05)
                : FractionalOffset(0.5, 0.95)),
        child: Text(
          widget.formatValue.call(
                  animation.value * widget.maxValue, widget.formatValueFixed) +
              widget.displayText!,
          softWrap: false,
          style: widget.displayTextStyle,
        ),
      );
      progressWidgets.add(textProgress);
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        width: widget.direction == Axis.vertical ? widget.size : null,
        height: widget.direction == Axis.horizontal ? widget.size : null,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: widget._borderRadius,
          border: widget.border,
        ),
        child: Flex(
          direction: widget.direction,
          verticalDirection: widget.verticalDirection,
          children: <Widget>[
            Expanded(
              flex: (animation.value * 100).toInt(),
              child: Stack(
                children: progressWidgets,
              ),
            ),
            Expanded(
              flex: 100 - (animation.value * 100).toInt(),
              child: Container(),
            )
          ],
        ),
      ),
    );
  }
}
