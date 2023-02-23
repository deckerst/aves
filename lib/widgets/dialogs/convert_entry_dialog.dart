import 'package:aves/model/entry.dart';
import 'package:aves/model/metadata/enums/enums.dart';
import 'package:aves/model/metadata/enums/length_unit.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/media/media_edit_service.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/utils/mime_utils.dart';
import 'package:aves/widgets/common/basic/text_dropdown_button.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';

import 'aves_dialog.dart';

class ConvertEntryDialog extends StatefulWidget {
  static const routeName = '/dialog/convert_entry';

  final Set<AvesEntry> entries;

  const ConvertEntryDialog({
    super.key,
    required this.entries,
  });

  @override
  State<ConvertEntryDialog> createState() => _ConvertEntryDialogState();
}

class _ConvertEntryDialogState extends State<ConvertEntryDialog> {
  final TextEditingController _widthController = TextEditingController(), _heightController = TextEditingController();
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(false);
  late String _mimeType;
  late bool _sameSized;
  late List<LengthUnit> _lengthUnitOptions;
  late LengthUnit _lengthUnit;

  Set<AvesEntry> get entries => widget.entries;

  static const imageExportFormats = [
    MimeTypes.bmp,
    MimeTypes.jpeg,
    MimeTypes.png,
    MimeTypes.webp,
  ];

  @override
  void initState() {
    super.initState();
    _mimeType = MimeTypes.jpeg;
    _sameSized = entries.map((entry) => entry.displaySize).toSet().length == 1;
    _lengthUnitOptions = [
      if (_sameSized) LengthUnit.px,
      LengthUnit.percent,
    ];
    _lengthUnit = _lengthUnitOptions.first;
    _initDimensions();
    _validate();
  }

  void _initDimensions() {
    switch (_lengthUnit) {
      case LengthUnit.px:
        final displaySize = entries.first.displaySize;
        _widthController.text = '${displaySize.width.round()}';
        _heightController.text = '${displaySize.height.round()}';
        break;
      case LengthUnit.percent:
        _widthController.text = '100';
        _heightController.text = '100';
        break;
    }
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const contentHorizontalPadding = EdgeInsets.symmetric(horizontal: AvesDialog.defaultHorizontalContentPadding);

    // used by the drop down to match input decoration
    final textFieldDecorationBorder = Border(
      bottom: BorderSide(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38), //Color(0xFFBDBDBD),
        width: 1.0,
      ),
    );

    return AvesDialog(
      scrollableContent: [
        const SizedBox(height: 16),
        Padding(
          padding: contentHorizontalPadding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.exportEntryDialogFormat),
              const SizedBox(width: AvesDialog.controlCaptionPadding),
              TextDropdownButton<String>(
                values: imageExportFormats,
                valueText: MimeUtils.displayType,
                value: _mimeType,
                onChanged: (selected) {
                  if (selected != null) {
                    setState(() => _mimeType = selected);
                  }
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: contentHorizontalPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: TextField(
                  controller: _widthController,
                  decoration: InputDecoration(labelText: l10n.exportEntryDialogWidth),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final width = int.tryParse(value);
                    if (width != null) {
                      switch (_lengthUnit) {
                        case LengthUnit.px:
                          _heightController.text = '${(width / entries.first.displayAspectRatio).round()}';
                          break;
                        case LengthUnit.percent:
                          _heightController.text = '$width';
                          break;
                      }
                    } else {
                      _heightController.text = '';
                    }
                    _validate();
                  },
                ),
              ),
              const SizedBox(width: 8),
              const Text(AvesEntry.resolutionSeparator),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _heightController,
                  decoration: InputDecoration(labelText: l10n.exportEntryDialogHeight),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final height = int.tryParse(value);
                    if (height != null) {
                      switch (_lengthUnit) {
                        case LengthUnit.px:
                          _widthController.text = '${(height * entries.first.displayAspectRatio).round()}';
                          break;
                        case LengthUnit.percent:
                          _widthController.text = '$height';
                          break;
                      }
                    } else {
                      _widthController.text = '';
                    }
                    _validate();
                  },
                ),
              ),
              const SizedBox(width: 16),
              TextDropdownButton<LengthUnit>(
                values: _lengthUnitOptions,
                valueText: (v) => v.getText(context),
                value: _lengthUnit,
                onChanged: _lengthUnitOptions.length > 1
                    ? (v) {
                        if (v != null && _lengthUnit != v) {
                          _lengthUnit = v;
                          _initDimensions();
                          _validate();
                          setState(() {});
                        }
                      }
                    : null,
                underline: Container(
                  height: 1.0,
                  decoration: BoxDecoration(
                    border: textFieldDecorationBorder,
                  ),
                ),
                itemHeight: 60,
                dropdownColor: Themes.thirdLayerColor(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
      actions: [
        const CancelButton(),
        ValueListenableBuilder<bool>(
          valueListenable: _isValidNotifier,
          builder: (context, isValid, child) {
            return TextButton(
              onPressed: isValid
                  ? () {
                      final width = int.tryParse(_widthController.text);
                      final height = int.tryParse(_heightController.text);
                      final options = (width != null && height != null)
                          ? EntryConvertOptions(
                              mimeType: _mimeType,
                              lengthUnit: _lengthUnit,
                              width: width,
                              height: height,
                            )
                          : null;
                      Navigator.maybeOf(context)?.pop(options);
                    }
                  : null,
              child: Text(l10n.applyButtonLabel),
            );
          },
        ),
      ],
    );
  }

  Future<void> _validate() async {
    final width = int.tryParse(_widthController.text);
    final height = int.tryParse(_heightController.text);
    _isValidNotifier.value = (width ?? 0) > 0 && (height ?? 0) > 0;
  }
}
