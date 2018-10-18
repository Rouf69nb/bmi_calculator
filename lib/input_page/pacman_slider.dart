import 'dart:math' as math;

import 'package:bmi_calculator/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const double _pacmanWidth = 21.0;
const double _sliderHorizontalMargin = 24.0;
const double _dotsLeftMargin = 16.0;

class PacmanSlider extends StatefulWidget {
  @override
  _PacmanSliderState createState() => _PacmanSliderState();
}

class _PacmanSliderState extends State<PacmanSlider>
    with TickerProviderStateMixin {
  final int numberOfDots = 10;
  final double minOpacity = 0.1;
  final double maxOpacity = 0.5;
  double _pacmanPosition = 24.0;
  AnimationController hintAnimationController;

  @override
  void initState() {
    super.initState();
    _initHintAnimationController();
    hintAnimationController.forward();
  }

  @override
  void dispose() {
    hintAnimationController.dispose();
    super.dispose();
  }

  void _initHintAnimationController() {
    hintAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    hintAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(Duration(milliseconds: 800), () {
          hintAnimationController.forward(from: 0.0);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenAwareSize(52.0, context),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        color: Theme.of(context).primaryColor,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
              alignment: Alignment.centerRight,
              children: <Widget>[
                _drawPacman(width: constraints.maxWidth),
                _drawDots(),
              ],
            ),
      ),
    );
  }

  Widget _drawPacman({double width}) {
    return Positioned(
      left: _pacmanPosition,
      child: GestureDetector(
        onHorizontalDragUpdate: (dragUpdate) {
          setState(() {
            _pacmanPosition += dragUpdate.delta.dx;
            _pacmanPosition = math.max(
              _pacmanMinPosition(),
                math.min(_pacmanMaxPosition(width),
                    _pacmanPosition));
          });
        },
        child: PacmanIcon(),
      ),
    );
  }

  double _pacmanMinPosition() =>
      screenAwareSize(_sliderHorizontalMargin, context);

  double _pacmanMaxPosition(double sliderWidth) => screenAwareSize(
      sliderWidth - _sliderHorizontalMargin - _pacmanWidth, context);

  Widget _drawDots() {
    return Padding(
      padding: EdgeInsets.only(
          left: screenAwareSize(_sliderHorizontalMargin + _pacmanWidth + _dotsLeftMargin, context),
          right: screenAwareSize(_sliderHorizontalMargin, context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(numberOfDots, _generateDot)
          ..add(Opacity(
            opacity: maxOpacity,
            child: Dot(size: 14.0),
          )),
      ),
    );
  }

  Widget _generateDot(int dotNumber) {
    Animation animation = _initDotAnimation(dotNumber);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Opacity(
            opacity: animation.value,
            child: child,
          ),
      child: Dot(size: 9.0),
    );
  }

  Animation<double> _initDotAnimation(int dotNumber) {
    double lastDotStartTime = 0.4;
    double dotAnimationDuration = 0.5;
    double begin = lastDotStartTime * dotNumber / numberOfDots;
    double end = begin + dotAnimationDuration;
    return SinusoidalAnimation(min: minOpacity, max: maxOpacity).animate(
      CurvedAnimation(
        parent: hintAnimationController,
        curve: Interval(begin, end),
      ),
    );
  }
}

class SinusoidalAnimation extends Animatable<double> {
  SinusoidalAnimation({this.min, this.max});

  final double min;
  final double max;

  @protected
  double lerp(double t) {
    return min + (max - min) * math.sin(math.pi * t);
  }

  @override
  double transform(double t) {
    return (t == 0.0 || t == 1.0) ? min : lerp(t);
  }
}

class Dot extends StatelessWidget {
  final double size;

  const Dot({Key key, @required this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenAwareSize(size, context),
      width: screenAwareSize(size, context),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
    );
  }
}

class PacmanIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
//        right: screenAwareSize(16.0, context),
          ),
      child: SvgPicture.asset(
        'images/pacman.svg',
        height: screenAwareSize(25.0, context),
        width: screenAwareSize(_pacmanWidth, context),
      ),
    );
  }
}
