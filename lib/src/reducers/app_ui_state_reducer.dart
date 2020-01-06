import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:redux/redux.dart';
import 'package:scadnano/src/state/context_menu.dart';
import 'package:scadnano/src/state/grid_position.dart';

import '../state/app_state.dart';
import '../state/app_ui_state.dart';
import '../state/mouseover_data.dart';
import '../reducers/select_mode_state_reducer.dart';
import '../reducers/edit_modes_reducer.dart';
import '../actions/actions.dart' as actions;
import 'strand_creation_reducer.dart';
import 'strands_move_reducer.dart';
import 'util_reducer.dart';
import 'selection_reducer.dart';
import 'mouseover_datas_reducer.dart';

////////////////////////////////////////////////////////////////////////////////////////////////////////
// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// ui state local reducer
// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

AppUIState ui_state_local_reducer(AppUIState ui_state, action) => ui_state.rebuild((u) => u
  ..changed_since_last_save = changed_since_last_save_reducer(ui_state.changed_since_last_save, action)
  ..select_mode_state.replace(select_mode_state_reducer(ui_state.select_mode_state, action))
  ..edit_modes.replace(edit_modes_reducer(ui_state.edit_modes, action))
  ..show_dna = TypedReducer<bool, actions.SetShowDNA>(show_dna_reducer)(ui_state.show_dna, action)
  ..show_mismatches =
      TypedReducer<bool, actions.SetShowMismatches>(show_mismatches_reducer)(ui_state.show_mismatches, action)
  ..show_editor = TypedReducer<bool, actions.SetShowEditor>(show_editor_reducer)(ui_state.show_editor, action)
  ..drawing_potential_crossover =
      drawing_potential_crossover_reducer(ui_state.drawing_potential_crossover, action)
  ..moving_dna_ends = moving_dna_ends_reducer(ui_state.moving_dna_ends, action)
  ..side_selected_helix_idxs.replace(side_selected_helices_reducer(ui_state.side_selected_helix_idxs, action))
  ..selectables_store.replace(selectables_store_reducer(ui_state.selectables_store, action))
  ..strands_move = strands_move_local_reducer(ui_state.strands_move, action)?.toBuilder()
  ..side_view_grid_position_mouse_cursor =
      side_view_mouse_grid_pos_reducer(ui_state.side_view_grid_position_mouse_cursor, action)?.toBuilder()
  ..side_view_position_mouse_cursor =
      side_view_position_mouse_cursor_reducer(ui_state.side_view_position_mouse_cursor, action)
  ..context_menu = context_menu_reducer(ui_state.context_menu, action)?.toBuilder()
//  ..selection_box_main_view = main_view_selection_box_reducer(ui_state.selection_box_main_view, action)?.toBuilder()
//  ..selection_box_side_view = side_view_selection_box_reducer(ui_state.selection_box_side_view, action)?.toBuilder()
  ..mouseover_datas.replace(mouseover_data_reducer(ui_state.mouseover_datas, action)));

Reducer<ContextMenu> context_menu_reducer = combineReducers([
  TypedReducer<ContextMenu, actions.ContextMenuShow>(context_menu_show_reducer),
  TypedReducer<ContextMenu, actions.ContextMenuHide>(context_menu_hide_reducer),
]);

ContextMenu context_menu_show_reducer(ContextMenu _, actions.ContextMenuShow action) => action.context_menu;

ContextMenu context_menu_hide_reducer(ContextMenu _, actions.ContextMenuHide action) => null;

Reducer<bool> drawing_potential_crossover_reducer = combineReducers([
  TypedReducer<bool, actions.PotentialCrossoverCreate>(potential_crossover_create_app_ui_state_reducer),
  TypedReducer<bool, actions.PotentialCrossoverRemove>(potential_crossover_remove_app_ui_state_reducer),
]);

Reducer<bool> moving_dna_ends_reducer = combineReducers([
  TypedReducer<bool, actions.DNAEndsMoveStart>(dna_ends_move_start_app_ui_state_reducer),
  TypedReducer<bool, actions.DNAEndsMoveStop>(dna_ends_move_stop_app_ui_state_reducer),
]);

bool potential_crossover_create_app_ui_state_reducer(bool _, actions.PotentialCrossoverCreate action) => true;

bool potential_crossover_remove_app_ui_state_reducer(bool _, actions.PotentialCrossoverRemove action) =>
    false;

bool dna_ends_move_start_app_ui_state_reducer(bool _, actions.DNAEndsMoveStart action) => true;

bool dna_ends_move_stop_app_ui_state_reducer(bool _, actions.DNAEndsMoveStop action) => false;

bool show_dna_reducer(bool prev_show, actions.SetShowDNA action) => action.show;

bool show_mismatches_reducer(bool prev_show, actions.SetShowMismatches action) => action.show;

bool show_editor_reducer(bool prev_show, actions.SetShowEditor action) => action.show;

Reducer<bool> show_mousever_rect_reducer = combineReducers([
  TypedReducer<bool, actions.ShowMouseoverRectSet>(show_mouseover_rect_set_reducer),
  TypedReducer<bool, actions.ShowMouseoverRectToggle>(show_mouseover_rect_toggle_reducer),
]);

bool show_mouseover_rect_set_reducer(bool prev_show, actions.ShowMouseoverRectSet action) => action.show;

bool show_mouseover_rect_toggle_reducer(bool prev_show, actions.ShowMouseoverRectToggle action) => !prev_show;

Reducer<bool> changed_since_last_save_reducer = combineReducers([
  TypedReducer<bool, actions.UndoableAction>(changed_since_last_save_undoable_action_reducer),
  TypedReducer<bool, actions.SaveDNAFile>(changed_since_last_save_just_saved_reducer),
]);

bool changed_since_last_save_undoable_action_reducer(
        bool changed_since_last_save, actions.UndoableAction action) =>
    true;

bool changed_since_last_save_just_saved_reducer(bool changed_since_last_save, actions.SaveDNAFile action) =>
    false;

Reducer<BuiltList<MouseoverData>> mouseover_data_reducer = combineReducers([
  TypedReducer<BuiltList<MouseoverData>, actions.MouseoverDataClear>(mouseover_data_clear_reducer),
]);

///////////////////////////////////////////////////////////////////////////////////////////////////
// side view mouse position/grid position reducers

Reducer<GridPosition> side_view_mouse_grid_pos_reducer = combineReducers([
  TypedReducer<GridPosition, actions.MouseGridPositionSideUpdate>(side_view_mouse_grid_pos_update_reducer),
  TypedReducer<GridPosition, actions.MouseGridPositionSideClear>(side_view_mouse_grid_pos_clear_reducer),
]);

GridPosition side_view_mouse_grid_pos_update_reducer(
        GridPosition _, actions.MouseGridPositionSideUpdate action) =>
    action.grid_position;

GridPosition side_view_mouse_grid_pos_clear_reducer(
        GridPosition _, actions.MouseGridPositionSideClear action) =>
    null;

Reducer<Point<num>> side_view_position_mouse_cursor_reducer = combineReducers([
  TypedReducer<Point<num>, actions.MousePositionSideUpdate>(side_view_mouse_pos_update_reducer),
  TypedReducer<Point<num>, actions.MousePositionSideClear>(side_view_mouse_pos_clear_reducer),
]);

Point<num> side_view_mouse_pos_update_reducer(Point<num> _, actions.MousePositionSideUpdate action) =>
    action.svg_pos;

Point<num> side_view_mouse_pos_clear_reducer(Point<num> _, actions.MousePositionSideClear action) => null;

/////////////////////////////////////////////////////////////////////////////////////////////////////////
// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// ui state global reducer
// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

AppUIState ui_state_global_reducer(AppUIState ui_state, AppState state, action) => ui_state.rebuild((u) => u
  ..mouseover_datas.replace(mouseover_datas_global_reducer(ui_state.mouseover_datas, state, action))
  ..strands_move = strands_move_global_reducer(ui_state.strands_move, state, action)?.toBuilder()
  ..strand_creation = strand_creation_global_reducer(ui_state.strand_creation, state, action)?.toBuilder()
  ..side_selected_helix_idxs
      .replace(side_selected_helices_global_reducer(ui_state.side_selected_helix_idxs, state, action))
  ..selectables_store.replace(selectables_store_global_reducer(ui_state.selectables_store, state, action)));

GlobalReducer<BuiltList<MouseoverData>, AppState> mouseover_datas_global_reducer = combineGlobalReducers([
  TypedGlobalReducer<BuiltList<MouseoverData>, AppState, actions.HelixRotationSet>(
      helix_rotation_set_mouseover_reducer),
  TypedGlobalReducer<BuiltList<MouseoverData>, AppState, actions.HelixRotationSetAtOther>(
      helix_rotation_set_at_other_mouseover_reducer),
  TypedGlobalReducer<BuiltList<MouseoverData>, AppState, actions.MouseoverDataUpdate>(
      mouseover_data_update_reducer),
]);
