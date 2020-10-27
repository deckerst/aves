import 'package:aves/model/filters/filters.dart';
import 'package:flutter/material.dart';

class BackUpNotification extends Notification {}

class FilterNotification extends Notification {
  final CollectionFilter filter;

  const FilterNotification(this.filter);
}
