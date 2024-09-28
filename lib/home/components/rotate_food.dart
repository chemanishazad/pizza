import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizza/const.dart';
import 'package:pizza/home/providers/transition_provider.dart';
import 'package:pizza/home/utils/utils.dart';

class RotateFood extends ConsumerStatefulWidget {
  const RotateFood({
    super.key,
    required this.currentIndex,
    required this.width,
    required this.pageController,
  });

  final PageController pageController;
  final int currentIndex;
  final double width;

  @override
  ConsumerState<RotateFood> createState() => _RotateFoodState();
}

class _RotateFoodState extends ConsumerState<RotateFood>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  double? lastAnimatedValue;
  Curve animationType = Curves.easeOutBack;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      upperBound: 1,
      lowerBound: 0,
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _rotateForward() {
    if (!_rotationController.isAnimating &&
        widget.currentIndex < foodList.length - 1) {
      setState(() {
        animationType = Curves.easeOutBack;
      });
      ref.read(textAnimationIndex.notifier).state = widget.currentIndex;
      widget.pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      _rotationController.forward(from: 0);
      lastAnimatedValue = 1;
    }
  }

  void _rotateBackward() {
    if (!_rotationController.isAnimating && widget.currentIndex > 0) {
      setState(() {
        animationType = Curves.easeInBack;
      });
      widget.pageController.previousPage(
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
      );
      _rotationController.reverse(from: lastAnimatedValue ?? 1);
      lastAnimatedValue = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => navigateToDetail(foodList[widget.currentIndex], context),
      onVerticalDragUpdate: (details) async {
        if (details.delta.dy <= 0) {
          _rotateForward();
        } else {
          _rotateBackward();
        }
      },
      child: Hero(
        tag: foodList[widget.currentIndex].pictureAlt!,
        flightShuttleBuilder: (flightContext, animation, flightDirection,
            fromHeroContext, toHeroContext) {
          return Image.asset(
            flightDirection == HeroFlightDirection.push
                ? "lib/assets/${foodList[widget.currentIndex].pictureAlt}"
                : "lib/assets/${foodList[widget.currentIndex].picture}",
            width: flightDirection == HeroFlightDirection.push
                ? widget.width * 0.80
                : widget.width * 0.88,
          ).animate().rotate(
                begin: flightDirection == HeroFlightDirection.push ? 1 : -1,
                end: 0,
                curve: flightDirection == HeroFlightDirection.push
                    ? Curves.fastOutSlowIn
                    : Curves.fastEaseInToSlowEaseOut,
                duration: const Duration(milliseconds: 600),
              );
        },
        child: _buildFoodImage(),
      ),
    )
        .animate()
        .rotate(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutBack,
          begin: 0,
          end: 0.2,
        )
        .then()
        .rotate(
          begin: 0,
          end: -0.2,
          curve: Curves.easeOutBack,
          duration: const Duration(milliseconds: 500),
        );
  }

  Widget _buildFoodImage() {
    return Image.asset(
      "lib/assets/${foodList[widget.currentIndex].picture}",
      width: widget.width * 0.88,
    )
        .animate(
          controller: _rotationController,
          autoPlay: false,
        )
        .rotate(
          duration: const Duration(milliseconds: 1200),
          alignment: Alignment.center,
          curve: animationType,
          begin: lastAnimatedValue == _rotationController.upperBound
              ? -_rotationController.upperBound
              : _rotationController.lowerBound,
          end: lastAnimatedValue == _rotationController.upperBound
              ? 0
              : _rotationController.upperBound,
        );
  }
}
