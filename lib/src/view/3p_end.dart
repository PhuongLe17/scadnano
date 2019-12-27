import 'dart:math';

import 'package:color/color.dart';
import 'package:over_react/over_react.dart';

import '5p_end.dart';

part '3p_end.over_react.g.dart';

@Factory()
UiFactory<End3PrimeProps> End3Prime = _$End3Prime;

@Props()
class _$End3PrimeProps extends UiProps implements EndEitherPrimeProps {
  PointerDownUpHandler on_pointer_down;
  PointerDownUpHandler on_pointer_up;
  MouseUpHandler on_mouse_up;
  String classname;
  Point<num> pos;
  Color color;
  bool forward;
  String id;
}

@Component2()
class End3PrimeComponent extends UiComponent2<End3PrimeProps> {
  @override
  render() {
    //XXX: width, height, rx, ry should be do-able in CSS. However, Firefox won't display properly
    // if they are specified in CSS, but it will if they are specified here.
    var points;
    num scale = 3.7;
    Point<num> pos = props.pos;
    if (!props.forward) {
      points = '${pos.x - scale},${pos.y} '
          '${pos.x + 0.9 * scale},${pos.y + scale} '
          '${pos.x + 0.9 * scale},${pos.y - scale}';
    } else {
      points = '${pos.x + scale},${pos.y} '
          '${pos.x - 0.9 * scale},${pos.y + scale} '
          '${pos.x - 0.9 * scale},${pos.y - scale}';
    }

    return (Dom.polygon()
      ..onPointerDown = props.on_pointer_down
      ..onPointerUp = props.on_pointer_up
      ..onMouseUp = props.on_mouse_up
      ..className = props.classname
      ..points = points
      ..id = props.id
      ..fill = props.color.toRgbColor().toCssString())();
  }
}