import 'package:carousel_slider/carousel_options.dart';
import 'package:flutter/cupertino.dart';

class Animation {
  Curve animationCurve;
  int durationMilliseconds;
  CenterPageEnlargeStrategy enlargeStrategy;
  bool enlargeCenter;
  bool reverse;
  double enlargeFactor;
  Axis scrollDirection;

  Animation({
    this.animationCurve = Curves.linear,
    this.durationMilliseconds = 100,
    this.enlargeStrategy = CenterPageEnlargeStrategy.scale,
    this.enlargeCenter = true,
    this.reverse = false,
    this.enlargeFactor = 0.4,
    this.scrollDirection = Axis.horizontal,
  });

  static List<String> getAnimationOptionsList() {
    return [
      "Padrão",
      "Instantâneo",
      "Slide",
      "Ricochete",
      "Elástico",
      "Crescente",
      "Rápido",
      "Devagar",
      "Previsão",
      "Invertido",
      "Vertical",
      "Vertical Invertido",
    ];
  }

  static Animation getAnimation(String effect) {
    switch (effect) {
      case "Instantâneo":
        return Animation(
          animationCurve: Curves.linear,
          durationMilliseconds: 500,
          enlargeStrategy: CenterPageEnlargeStrategy.height,
        );

      case "Ricochete":
        return Animation(
          animationCurve: Curves.bounceOut,
          durationMilliseconds: 1600,
          enlargeStrategy: CenterPageEnlargeStrategy.height,
        );

      case "Slide":
        return Animation(
          animationCurve: Curves.easeOutExpo,
          durationMilliseconds: 3200,
          enlargeCenter: false,
        );

      case "Crescente":
        return Animation(
          animationCurve: Curves.easeInOutCubicEmphasized,
          durationMilliseconds: 2800,
          enlargeFactor: 0.8,
        );

      case "Rápido":
        return Animation(
          animationCurve: Curves.easeInOutCubicEmphasized,
          durationMilliseconds: 3200,
          enlargeCenter: false,
        );

      case "Elástico":
        return Animation(
          animationCurve: Curves.elasticInOut,
          durationMilliseconds: 2400,
          enlargeStrategy: CenterPageEnlargeStrategy.zoom,
        );

      case "Devagar":
        return Animation(
          animationCurve: Curves.easeInOutSine,
          durationMilliseconds: 1600,
        );

      case "Previsão":
        return Animation(
          animationCurve: Curves.slowMiddle,
          durationMilliseconds: 1000,
          enlargeFactor: 0.6,
          enlargeStrategy: CenterPageEnlargeStrategy.zoom,
          enlargeCenter: true,
        );

      case "Vertical":
        return Animation(
          animationCurve: Curves.linearToEaseOut,
          durationMilliseconds: 1100,
          enlargeStrategy: CenterPageEnlargeStrategy.zoom,
          enlargeCenter: true,
          enlargeFactor: 0.5,
          scrollDirection: Axis.vertical,
        );

      case "Vertical Invertido":
        return Animation(
          animationCurve: Curves.linearToEaseOut,
          durationMilliseconds: 1100,
          enlargeStrategy: CenterPageEnlargeStrategy.zoom,
          enlargeCenter: true,
          enlargeFactor: 0.5,
          scrollDirection: Axis.vertical,
          reverse: true,
        );

      case "Invertido":
        return Animation(
          animationCurve: Curves.linearToEaseOut,
          durationMilliseconds: 900,
          reverse: true,
        );

      case "Padrão":
      default:
        return Animation(
          animationCurve: Curves.linearToEaseOut,
          durationMilliseconds: 900,
        );
    }
  }
}