import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizza/const.dart';
import 'package:pizza/home/components/food.dart';
import 'package:pizza/home/components/rotate_food.dart';
import 'package:pizza/home/providers/transition_provider.dart';
import 'package:pizza/home/utils/utils.dart';
import 'package:pizza/services/precache_service.dart';
import 'package:unicons/unicons.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  int currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void didChangeDependencies() {
    PreCacheImages.preCacheImages(context);
    super.didChangeDependencies();
  }

  void _loopPageView(int index) {
    if (index == 3) {
      _pageController.jumpToPage(0);
    } else if (index < 0) {
      _pageController.jumpToPage(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Transform(
        transform: Matrix4.identity()..rotateZ(pi / 4),
        alignment: Alignment.center,
        child: Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: const Color(0xff45C37B).withOpacity(0.5),
              offset: const Offset(2, 5),
              blurRadius: 15,
            )
          ]),
          child: FloatingActionButton(
            mini: true,
            elevation: 0,
            backgroundColor: const Color(0xff45C37B),
            onPressed: () => navigateToDetail(foodList[currentIndex], context),
            child: Transform(
              transform: Matrix4.identity()..rotateZ(-pi / 4),
              alignment: Alignment.center,
              child: Icon(
                UniconsLine.arrow_right,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          PageView.builder(
            physics: const NeverScrollableScrollPhysics(),
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: (value) {
              setState(() {
                currentIndex = value % 3;
              });
              ref.read(textAnimationIndex.notifier).state = null;
              _loopPageView(value);
            },
            itemBuilder: (context, index) {
              return Container(
                color: foodList[index % 3].colorScheme!.onPrimary,
              );
            },
            itemCount: 3,
          ),
          Food(
            foodDetail: foodList[currentIndex],
            pageController: _pageController,
          ),
          Positioned(
            top: height / 2 - (width * 0.88) / 2,
            left: width / 2 - 20,
            child: RotateFood(
              currentIndex: currentIndex,
              width: width,
              pageController: _pageController,
            ),
          )
        ],
      ),
    );
  }
}
