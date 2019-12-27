import 'dart:html';
import 'dart:math';

import 'package:color/color.dart';
import 'package:over_react/over_react.dart';
import 'package:over_react/over_react_redux.dart';
import 'package:react/react.dart' as react;

//import 'package:dnd/dnd.dart';

import 'package:scadnano/src/state/edit_mode.dart';
import 'package:scadnano/src/state/dna_end.dart';
import 'package:scadnano/src/state/helix.dart';
import 'package:scadnano/src/state/potential_crossover.dart';
import '../state/app_state.dart';
import 'package:scadnano/src/state/select_mode.dart';
import '../state/bound_substrand.dart';
import '../app.dart';
import '5p_end.dart';
import '3p_end.dart';
import 'design_main_strand_dna_end_moving.dart';
import 'design_main.dart';
import '../actions/actions.dart' as actions;

part 'design_main_strand_dna_end.over_react.g.dart';

Map mapStateToPropsWithOwnProps(AppState state, DesignMainDNAEndProps props) {
  DNAEnd end = props.is_5p ? props.substrand.dnaend_5p : props.substrand.dnaend_3p;
  return DesignMainDNAEnd()
    ..selected = state.ui_state.selectables_store.selected(end)
    ..selectable = state.ui_state.select_mode_state.is_selectable(end)
    ..select_mode = state.ui_state.edit_modes.contains(EditModeChoice.select)
    ..helix = state.dna_design.helices[props.substrand.helix]
    ..pencil_mode = state.ui_state.edit_modes.contains(EditModeChoice.pencil)
    ..join_mode = state.ui_state.edit_modes.contains(EditModeChoice.ligate)
    ..moving_this_dna_end = state.ui_state.moving_dna_ends && state.ui_state.selectables_store.selected(end)
    ..drawing_potential_crossover = state.ui_state.drawing_potential_crossover;
}

UiFactory<DesignMainDNAEndProps> ConnectedDesignMainDNAEnd = connect<AppState, DesignMainDNAEndProps>(
    mapStateToPropsWithOwnProps: mapStateToPropsWithOwnProps)(DesignMainDNAEnd);

@Factory()
UiFactory<DesignMainDNAEndProps> DesignMainDNAEnd = _$DesignMainDNAEnd;

@Props()
class _$DesignMainDNAEndProps extends UiProps {
  BoundSubstrand substrand;
  Color color;
  bool is_5p;

  Helix helix;
  bool selected;
  bool selectable;
  bool select_mode;
  bool pencil_mode;
  bool join_mode;
  bool drawing_potential_crossover;
  bool moving_this_dna_end;
}

@Component2()
class DesignMainDNAEndComponent extends UiComponent2<DesignMainDNAEndProps> {
  DNAEnd get dna_end => props.is_5p ? props.substrand.dnaend_5p : props.substrand.dnaend_3p;

  bool get is_first => props.substrand.is_first && props.is_5p;

  bool get is_last => props.substrand.is_last && !props.is_5p;

  @override
  render() {
    var classname = '${props.is_5p ? 'five' : 'three'}-prime-end' +
        (is_first && props.is_5p ? '-first-substrand' : '') +
        (is_last && !props.is_5p ? '-last-substrand' : '');

//    if (substrand.selected_5p()) {
    if (props.selected) {
      classname += ' selected';
    }
    if (props.selectable) {
      classname += ' selectable';
    }

    //[{ isDragging }, drag]
    if (USING_REACT_DND) {
//      var param = {
//        'item': {'type': '5p'},
//        'collect': (monitor) => {
//              'isDragging': monitor.isDragging(),
//            },
//      };
//      List drag_ret = useDrag(param);
//      var props = drag_ret[0];
//      var drag = drag_ret[1];
//      bool isDragging = props['isDragging'];
    } else {
      //XXX: need to listen to onPointerDown instead of onMouseDown for when draggable is enabled,
      // which it is when Shift or Ctrl (or Meta) keys are pressed
      // see here: https://github.com/marcojakob/dart-dnd/issues/27
      BoundSubstrand substrand = this.props.substrand;
      DNAEnd dna_end = props.is_5p ? substrand.dnaend_5p : substrand.dnaend_3p;
      var helix = app.state.dna_design.helices[substrand.helix];
      var offset = props.is_5p ? substrand.offset_5p : substrand.offset_3p;
      var pos = helix.svg_base_pos(offset, substrand.forward);
      EndEitherPrimeProps end_props = (props.is_5p ? End5Prime() : End3Prime());
      end_props = end_props
        ..on_pointer_down = handle_end_click_select_and_or_move_start
        ..on_pointer_up = handle_end_pointer_up_select
        ..on_mouse_up = ((ev) => handle_end_click_ligate_or_potential_crossover())
        ..pos = pos
        ..color = props.color
        ..classname = classname
        ..forward = substrand.forward
        ..id = dna_end.id()
        ..key = 'nonmoving-end';

      // draw avatar of moving DNA end if it is moving
      EndMovingProps end_moving_props = ConnectedEndMoving();
      end_moving_props = end_moving_props
        ..dna_end = dna_end
        ..original_offset = offset
        ..color = props.color
        ..forward = substrand.forward
        ..helix = helix
        ..is_5p = props.is_5p
        ..key = 'moving-end';

      return [
        end_props(),
        end_moving_props(),
      ];

//      if (props.moving_this_dna_end) {
//        //XXX: change second option
//        EndMovingEitherPrimeProps end_moving_props = props.is_5p ? EndMoving5Prime() : EndMoving5Prime();
//        DNAEnd dna_end = props.is_5p ? substrand.dnaend_5p : substrand.dnaend_3p;
//        end_moving_props = end_moving_props
//          ..dna_end = dna_end
//          ..original_offset = offset
//          ..color = props.color
//          ..forward = substrand.forward
//          ..helix = helix;
//        return [
//          end_props(),
//          end_moving_props(),
//        ];
//      } else {
//        return end_props();
//      }

//      EndMovingEitherPrimeProps end_moving_props = (props.is_5p ? EndMoving5Prime() : EndMoving3Prime());
//      end_moving_props = end_moving_props
//        ..original_offset = pos
//        ..color = props.color
//        ..classname = classname
//        ..id = id;
//      if (!props.is_5p) {
//        (end_props as End3PrimeProps).forward = substrand.forward;
//      }
////      return (end_props(),);
    }
  }

//  handle_end_click_select_and_or_move(react.SyntheticPointerEvent event) {
  handle_end_click_select_and_or_move_start(react.SyntheticPointerEvent event_synthetic) {
    // select end
    if (props.select_mode && props.selectable) {
      MouseEvent event = event_synthetic.nativeEvent;
      dna_end.handle_selection_mouse_down(event);
    }

    if (props.select_mode) {
      // set up drag detection for moving DNA ends
      app.dispatch(actions.DNAEndsMoveStart(offset: dna_end.offset_inclusive, helix: props.helix));
    }
  }

  handle_end_pointer_up_select(react.SyntheticPointerEvent event_synthetic) {
    if (props.select_mode && props.selectable) {
      MouseEvent event = event_synthetic.nativeEvent;
      dna_end.handle_selection_mouse_up(event);
    }
  }

  handle_end_click_ligate_or_potential_crossover() {
    if (props.pencil_mode && !props.drawing_potential_crossover && (is_first || is_last)) {
      int offset = props.is_5p ? props.substrand.offset_5p : props.substrand.offset_3p;
      Point<num> start_point = props.helix.svg_base_pos(offset, props.substrand.forward);
      var potential_crossover = PotentialCrossover(
        helix_idx: props.helix.idx,
        forward: props.substrand.forward,
        offset: offset,
        color: props.color.toHexColor().toCssString(),
        dna_end_first_click: dna_end,
        start_point: start_point,
        current_point: start_point,
      );
      app.dispatch(actions.PotentialCrossoverCreate(potential_crossover: potential_crossover));
    } else if (props.pencil_mode && props.drawing_potential_crossover && (is_first || is_last)) {
      PotentialCrossover potential_crossover = app.store_potential_crossover.state;

      //FIXME: can we avoid this global variable access? probably not since there's multiple stores
      app.dispatch(actions.PotentialCrossoverRemove());
      if ((is_first && potential_crossover.dna_end_first_click.substrand_is_last) ||
          (is_last && potential_crossover.dna_end_first_click.substrand_is_first)) {
        app.dispatch(actions.JoinStrandsByCrossover(
            potential_crossover: potential_crossover, dna_end_second_click: dna_end));
      }
    } else if (props.join_mode && (is_first || is_last)) {
      app.dispatch(actions.Ligate(dna_end: dna_end));
    }
  }
}