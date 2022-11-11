import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/utils/time_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_caption.dart';
import 'package:aves/widgets/dialogs/aves_selection_dialog.dart';
import 'package:aves/widgets/dialogs/duration_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsSubPageTile extends StatelessWidget {
  final String title, routeName;
  final WidgetBuilder builder;

  const SettingsSubPageTile({
    super.key,
    required this.title,
    required this.routeName,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: RouteSettings(name: routeName),
            builder: builder,
          ),
        );
      },
    );
  }
}

class SettingsSwitchListTile extends StatelessWidget {
  final bool Function(BuildContext, Settings) selector;
  final ValueChanged<bool> onChanged;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SettingsSwitchListTile({
    super.key,
    required this.selector,
    required this.onChanged,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<Settings, bool>(
      selector: selector,
      builder: (context, current, child) {
        Widget titleWidget = Text(title);
        if (trailing != null) {
          titleWidget = Row(
            children: [
              Expanded(child: titleWidget),
              AnimatedOpacity(
                opacity: current ? 1 : .2,
                duration: Durations.toggleableTransitionAnimation,
                child: trailing,
              ),
            ],
          );
        }
        return SwitchListTile(
          value: current,
          onChanged: onChanged,
          title: titleWidget,
          subtitle: subtitle != null ? Text(subtitle!) : null,
        );
      },
    );
  }
}

class SettingsSelectionListTile<T extends Enum> extends StatelessWidget {
  final List<T> values;
  final String Function(BuildContext, T) getName;
  final T Function(BuildContext, Settings) selector;
  final ValueChanged<T> onSelection;
  final String tileTitle;
  final String? dialogTitle;
  final TextBuilder<T>? optionSubtitleBuilder;

  const SettingsSelectionListTile({
    super.key,
    required this.values,
    required this.getName,
    required this.selector,
    required this.onSelection,
    required this.tileTitle,
    this.dialogTitle,
    this.optionSubtitleBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<Settings, T>(
      selector: selector,
      builder: (context, current, child) => ListTile(
        title: Text(tileTitle),
        subtitle: AvesCaption(getName(context, current)),
        onTap: () => showSelectionDialog<T>(
          context: context,
          builder: (context) => AvesSelectionDialog<T>(
            initialValue: current,
            options: Map.fromEntries(values.map((v) => MapEntry(v, getName(context, v)))),
            optionSubtitleBuilder: optionSubtitleBuilder,
            title: dialogTitle,
          ),
          onSelection: onSelection,
        ),
      ),
    );
  }
}

class SettingsDurationListTile extends StatelessWidget {
  final int Function(BuildContext, Settings) selector;
  final ValueChanged<int> onChanged;
  final String title;

  const SettingsDurationListTile({
    super.key,
    required this.selector,
    required this.onChanged,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<Settings, int>(
      selector: selector,
      builder: (context, current, child) {
        final currentMinutes = current ~/ secondsInMinute;
        final currentSeconds = current % secondsInMinute;

        final l10n = context.l10n;
        final subtitle = [
          if (currentMinutes > 0) l10n.timeMinutes(currentMinutes),
          if (currentSeconds > 0) l10n.timeSeconds(currentSeconds),
        ].join(' ');

        return ListTile(
          title: Text(title),
          subtitle: AvesCaption(subtitle),
          onTap: () async {
            final v = await showDialog<int>(
              context: context,
              builder: (context) => DurationDialog(initialSeconds: current),
            );
            if (v != null) {
              onChanged(v);
            }
          },
        );
      },
    );
  }
}
