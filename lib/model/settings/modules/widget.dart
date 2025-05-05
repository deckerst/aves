import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/defaults.dart';
import 'package:aves_model/aves_model.dart';

mixin WidgetSettings on SettingsAccess {
  WidgetOutline getWidgetOutline(int widgetId) => getEnumOrDefault('${SettingKeys.widgetOutlinePrefixKey}$widgetId', WidgetOutline.none, WidgetOutline.values);

  void setWidgetOutline(int widgetId, WidgetOutline newValue) => set('${SettingKeys.widgetOutlinePrefixKey}$widgetId', newValue.toString());

  WidgetShape getWidgetShape(int widgetId) => getEnumOrDefault('${SettingKeys.widgetShapePrefixKey}$widgetId', SettingsDefaults.widgetShape, WidgetShape.values);

  void setWidgetShape(int widgetId, WidgetShape newValue) => set('${SettingKeys.widgetShapePrefixKey}$widgetId', newValue.toString());

  Set<CollectionFilter> getWidgetCollectionFilters(int widgetId) => (getStringList('${SettingKeys.widgetCollectionFiltersPrefixKey}$widgetId') ?? []).map(CollectionFilter.fromJson).nonNulls.toSet();

  void setWidgetCollectionFilters(int widgetId, Set<CollectionFilter> newValue) => set('${SettingKeys.widgetCollectionFiltersPrefixKey}$widgetId', newValue.map((filter) => filter.toJson()).toList());

  WidgetOpenPage getWidgetOpenPage(int widgetId) => getEnumOrDefault('${SettingKeys.widgetOpenPagePrefixKey}$widgetId', SettingsDefaults.widgetOpenPage, WidgetOpenPage.values);

  void setWidgetOpenPage(int widgetId, WidgetOpenPage newValue) => set('${SettingKeys.widgetOpenPagePrefixKey}$widgetId', newValue.toString());

  WidgetDisplayedItem getWidgetDisplayedItem(int widgetId) => getEnumOrDefault('${SettingKeys.widgetDisplayedItemPrefixKey}$widgetId', SettingsDefaults.widgetDisplayedItem, WidgetDisplayedItem.values);

  void setWidgetDisplayedItem(int widgetId, WidgetDisplayedItem newValue) => set('${SettingKeys.widgetDisplayedItemPrefixKey}$widgetId', newValue.toString());

  String? getWidgetUri(int widgetId) => getString('${SettingKeys.widgetUriPrefixKey}$widgetId');

  void setWidgetUri(int widgetId, String? newValue) => set('${SettingKeys.widgetUriPrefixKey}$widgetId', newValue);
}
