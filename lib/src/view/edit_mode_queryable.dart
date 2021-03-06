import 'package:built_collection/built_collection.dart';
import 'package:over_react/over_react.dart';
import 'package:scadnano/src/state/edit_mode.dart';

part 'edit_mode_queryable.over_react.g.dart';

mixin EditModePropsMixin on UiProps {
  BuiltSet<EditModeChoice> edit_modes;
}

abstract class EditModeQueryable<P extends EditModePropsMixin> {
  P get props;

  bool get select_mode => props.edit_modes.contains(EditModeChoice.select);

  bool get pencil_mode => props.edit_modes.contains(EditModeChoice.pencil);

  bool get nick_mode => props.edit_modes.contains(EditModeChoice.nick);

  bool get ligate_mode => props.edit_modes.contains(EditModeChoice.ligate);

  bool get insertion_mode => props.edit_modes.contains(EditModeChoice.insertion);

  bool get deletion_mode => props.edit_modes.contains(EditModeChoice.deletion);

  bool get backbone_mode => props.edit_modes.contains(EditModeChoice.backbone);
}
