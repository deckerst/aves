import 'dart:async';

import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/text.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_caption.dart';
import 'package:aves/widgets/dialogs/duration_dialog.dart';
import 'package:aves/widgets/dialogs/selection_dialogs/common.dart';
import 'package:aves/widgets/dialogs/selection_dialogs/multi_selection.dart';
import 'package:aves/widgets/dialogs/selection_dialogs/single_selection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef TitleBuilder = String? Function(BuildContext context);

class SettingsSubPageTile extends StatelessWidget {
  final TitleBuilder title;
  final WidgetBuilder? subtitle;
  final String routeName;
  final WidgetBuilder builder;

  const SettingsSubPageTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.routeName,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title(context) ?? '?'),
      subtitle: subtitle?.call(context),
      onTap: () {
        Navigator.maybeOf(context)?.push(
          MaterialPageRoute(
            settings: RouteSettings(name: routeName),
            builder: builder,
          ),
        );
      },
    );
  }
}

class SettingsSwitchListTile extends StatefulWidget {
  final bool Function(BuildContext, Settings) selector;
  final FutureOr<void> Function(bool value)? onChanged;
  final Widget? leading;
  final TitleBuilder title;
  final TitleBuilder? subtitle;
  final Widget? trailing;

  static const disabledOpacity = .2;

  const SettingsSwitchListTile({
    super.key,
    required this.selector,
    required this.onChanged,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  State<SettingsSwitchListTile> createState() => _SettingsSwitchListTileState();
}

class _SettingsSwitchListTileState extends State<SettingsSwitchListTile> {
  @override
  Widget build(BuildContext context) {
    return Selector<Settings, bool>(
      selector: widget.selector,
      builder: (context, current, child) {
        Widget? leading = widget.leading;
        Widget titleWidget = Text(widget.title(context) ?? '?');
        final subtitle = widget.subtitle?.call(context);
        final trailing = widget.trailing;
        final onChanged = widget.onChanged;

        if (leading != null) {
          leading = AnimatedOpacity(
            opacity: current && onChanged != null ? 1 : SettingsSwitchListTile.disabledOpacity,
            duration: ADurations.toggleableTransitionLoose,
            child: leading,
          );
        }

        if (trailing != null) {
          titleWidget = Row(
            children: [
              Expanded(child: titleWidget),
              AnimatedOpacity(
                opacity: current && onChanged != null ? 1 : SettingsSwitchListTile.disabledOpacity,
                duration: ADurations.toggleableTransitionLoose,
                child: trailing,
              ),
            ],
          );
        }

        return SwitchListTile(
          value: current,
          onChanged: onChanged != null
              ? (v) async {
                  await onChanged(v);
                  // update in case other props (e.g. subtitle) changed as a consequence
                  setState(() {});
                }
              : null,
          title: titleWidget,
          subtitle: subtitle != null ? Text(subtitle) : null,
          secondary: leading,
        );
      },
    );
  }
}

class SettingsSelectionListTile<T> extends StatelessWidget {
  final List<T> values;
  final String Function(BuildContext, T) getName;
  final T Function(BuildContext, Settings) selector;
  final ValueChanged<T> onSelection;
  final TitleBuilder tileTitle;
  final WidgetBuilder? trailingBuilder;
  final String? dialogTitle;
  final TextBuilder<T>? optionSubtitleBuilder;

  const SettingsSelectionListTile({
    super.key,
    required this.values,
    required this.getName,
    required this.selector,
    required this.onSelection,
    required this.tileTitle,
    this.trailingBuilder,
    this.dialogTitle,
    this.optionSubtitleBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<Settings, T>(
      selector: selector,
      builder: (context, current, child) {
        return ListTile(
          title: Text(tileTitle(context) ?? '?'),
          subtitle: AvesCaption(getName(context, current)),
          trailing: trailingBuilder?.call(context),
          onTap: () => showSelectionDialog<T>(
            context: context,
            builder: (context) => AvesSingleSelectionDialog<T>(
              initialValue: current,
              options: Map.fromEntries(values.map((v) => MapEntry(v, getName(context, v)))),
              optionSubtitleBuilder: optionSubtitleBuilder,
              title: dialogTitle,
            ),
            onSelection: onSelection,
          ),
        );
      },
    );
  }
}

class SettingsMultiSelectionListTile<T> extends StatelessWidget {
  final List<T> values;
  final String Function(BuildContext, T) getName;
  final List<T> Function(BuildContext, Settings) selector;
  final ValueChanged<List<T>> onSelection;
  final String tileTitle, noneSubtitle;
  final String? dialogTitle;
  final TextBuilder<T>? optionSubtitleBuilder;

  const SettingsMultiSelectionListTile({
    super.key,
    required this.values,
    required this.getName,
    required this.selector,
    required this.onSelection,
    required this.tileTitle,
    required this.noneSubtitle,
    this.dialogTitle,
    this.optionSubtitleBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<Settings, List<T>>(
      selector: selector,
      builder: (context, current, child) {
        return ListTile(
          title: Text(tileTitle),
          subtitle: AvesCaption(current.isEmpty ? noneSubtitle : current.map((v) => getName(context, v)).join(AText.separator)),
          onTap: () => showSelectionDialog<List<T>>(
            context: context,
            builder: (context) => AvesMultiSelectionDialog<T>(
              initialValue: current.toSet(),
              options: Map.fromEntries(values.map((v) => MapEntry(v, getName(context, v)))),
              optionSubtitleBuilder: optionSubtitleBuilder,
              title: dialogTitle,
            ),
            onSelection: onSelection,
          ),
        );
      },
    );
  }
}

class SettingsDurationListTile extends StatelessWidget {
  final int Function(BuildContext, Settings) selector;
  final ValueChanged<int> onChanged;
  final TitleBuilder title;

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
        final currentMinutes = current ~/ Duration.secondsPerMinute;
        final currentSeconds = current % Duration.secondsPerMinute;

        final l10n = context.l10n;
        final subtitle = [
          if (currentMinutes > 0) l10n.timeMinutes(currentMinutes),
          if (currentSeconds > 0) l10n.timeSeconds(currentSeconds),
        ].join(' ');

        return ListTile(
          title: Text(title(context) ?? '?'),
          subtitle: AvesCaption(subtitle),
          onTap: () async {
            final seconds = await showDialog<int>(
              context: context,
              builder: (context) => DurationDialog(initialSeconds: current),
            );
            if (seconds != null) {
              onChanged(seconds);
            }
          },
        );
      },
    );
  }
}
