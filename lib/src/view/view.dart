@JS()
library view;

import 'dart:html';

import 'package:js/js.dart';
import 'package:over_react/react_dom.dart' as react_dom;
import 'package:scadnano/src/model/model.dart';

import 'design.dart';
import 'menu.dart';
import 'editor.dart';
import '../app.dart';

import '../constants.dart' as constants;

//TODO: display message while app is loading so it looks like something is happening

@JS(constants.js_function_name_setup_svg_panzoom)
external setup_svg_panzoom_js();

@JS(constants.js_function_name_setup_splits)
external setup_splits(bool show_editor);

@JS(constants.js_function_name_sdrag)
external sdrag_js();

const MENU_ID = 'menu';
const DESIGN_ID = 'design-pane';
const EDITOR_ID = 'editor-pane';
const NONMENU_PANES_CONTAINER_ID = 'nonmenu-panes-container';

/// Most views clear out their root element on each render, but View is a little special, so some
/// elements are put in place in the DOM in the constructor and never moved again. It is expected that
/// only one View object is ever created during the lifetime of the app. (in particular we should not need
/// to call setup_splits() more than once).
class View {
  final DivElement root_element;

  final Model model;

  DivElement nonmenu_panes_container_element = DivElement()..attributes = {'id': NONMENU_PANES_CONTAINER_ID};
  DivElement menu_element = DivElement()..attributes = {'id': MENU_ID};
  DivElement design_element = DivElement()..attributes = {'id': DESIGN_ID};
  DivElement design_editor_separator = DivElement()
    ..attributes = {'id': 'design-editor-separator', 'class': 'draggable-separator'};
  DivElement editor_element = DivElement()..attributes = {'id': EDITOR_ID};

  DesignViewComponent design_view;
  EditorViewComponent editor_view;

  bool currently_showing_editor = app.model.show_editor;

  View(this.root_element, this.model) {
    this.root_element.children.add(menu_element);
    this.root_element.children.add(DivElement()..attributes = {'class': 'fixed-separator'});
    this.root_element.children.add(this.nonmenu_panes_container_element);

    this.nonmenu_panes_container_element.children.add(design_element);

    this.design_view = DesignViewComponent(design_element, this.model);
//    this.editor_view = EditorViewComponent(editor_element);

//    setup_splits(app.model.show_editor);
    this.model.listen((_) => this.render());
  }

  /// This should be called whenever app.model is set to a new object,
  /// to redraw the entire app. It should NOT be called when the model changes
  /// in place. Instead, individual view elements should be notified as needed,
  /// using the notifier streams defined in Controller.
  render() {
//    this.update_showing_editor();

    react_dom.render((Menu()..store = app.model.show_store)(), querySelector('#$MENU_ID'));

    this.design_view.render();

//    if (app.model.show_editor) {
//      this.editor_view.render();
//    }
  }

//  update_showing_editor() {
//    //TODO: Firefox won't let editor pane shrink (when pan separater is dragged) to hide text; Chrome puts a scrollbar
//    // at the bottom when that happens and lets the editor pane shrink arbitrarily (which is the desired behavior)
//
//    if (!this.currently_showing_editor && app.model.show_editor) {
//      this.nonmenu_panes_container_element.children.add(design_editor_separator);
//      this.nonmenu_panes_container_element.children.add(editor_element);
//      this.currently_showing_editor = true;
//      setup_splits(app.model.show_editor);
//      this.editor_view.render();
//    } else if (this.currently_showing_editor && !app.model.show_editor) {
//      this.nonmenu_panes_container_element.children.remove(design_editor_separator);
//      this.nonmenu_panes_container_element.children.remove(editor_element);
//      this.currently_showing_editor = false;
//      setup_splits(app.model.show_editor);
//      this.editor_view.render();
//    }
//  }
}