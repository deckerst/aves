import 'package:aves/model/filters/filters.dart';
import 'package:aves_model/aves_model.dart';
import 'package:material_ui/material_ui.dart';

abstract class const ExplorerNotification() extends Notification;

@immutable
class const GoToDirectoryNotification(final VolumeRelativeDirectory? dir) extends ExplorerNotification;

@immutable
class const GoToPathNotification(final String path) extends ExplorerNotification;

@immutable
class const GoToCollectionPageNotification(final CollectionFilter filter) extends ExplorerNotification;
