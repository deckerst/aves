import 'package:aves/model/app/support.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/multipage.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/media/media_edit_service.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/text.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/utils/mime_utils.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/basic/list_tiles/slider.dart';
import 'package:aves/widgets/common/basic/text/change_highlight.dart';
import 'package:aves/widgets/common/basic/text_dropdown_button.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/fx/transitions.dart';
import 'package:aves_model/aves_model.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'aves_dialog.dart';

class const ConvertEntryDialog({
  super.key,
  required final Set<AvesEntry> entries,
}) extends StatefulWidget {
  static const routeName = '/dialog/convert_entry';

  @override
  State<ConvertEntryDialog> createState() => _ConvertEntryDialogState();
}

class _ConvertEntryDialogState extends State<ConvertEntryDialog> {
  late List<EntryConvertAction> _actionOptions;
  final ValueNotifier<EntryConvertAction> _actionNotifier = ValueNotifier(.convert);
  final ValueNotifier<String> _mimeTypeNotifier = ValueNotifier('');
  final ValueNotifier<ConvertDimension> _targetDimensionNotifier = ValueNotifier(.both);
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final ValueNotifier<List<LengthUnit>> _lengthUnitOptionsNotifier = ValueNotifier([]);
  final ValueNotifier<LengthUnit> _lengthUnitNotifier = ValueNotifier(.percent);
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(false);
  late int _quality;
  late bool _writeMetadata, _sameSized;

  Set<AvesEntry> get entries => widget.entries;

  EdgeInsets get contentHorizontalPadding => const EdgeInsets.symmetric(horizontal: AvesDialog.defaultHorizontalContentPadding);

  static const _imageExportFormats = [
    MimeTypes.jpeg,
    MimeTypes.png,
    MimeTypes.webp,
  ];

  static const _qualityFormats = [
    MimeTypes.jpeg,
    MimeTypes.webp,
  ];

  @override
  void initState() {
    super.initState();
    _actionOptions = [
      .convert,
      if (entries.any((entry) => entry.isMotionPhoto)) .convertMotionPhotoToStillImage,
    ];
    _mimeTypeNotifier.value = settings.convertMimeType;
    _quality = settings.convertQuality;
    _writeMetadata = settings.convertWriteMetadata;
    _sameSized = entries.map((entry) => entry.displaySize).toSet().length == 1;

    _updateLengthUnitOptions();
    _updateLengthUnit();
    _updateDimensions();
    _validate();

    _actionNotifier.addListener(_validate);
    _targetDimensionNotifier.addListener(_onTargetDimensionChanged);
    _widthController.addListener(_validate);
    _heightController.addListener(_validate);
    _lengthUnitOptionsNotifier.addListener(_updateLengthUnit);
    _lengthUnitNotifier.addListener(_updateDimensions);
  }

  void _onTargetDimensionChanged() {
    _updateLengthUnitOptions();
    _validate();
  }

  void _updateLengthUnitOptions() {
    _lengthUnitOptionsNotifier.value = [
      if (_sameSized || _targetDimensionNotifier.value != .both) LengthUnit.px,
      LengthUnit.percent,
    ];
  }

  void _updateLengthUnit() {
    _lengthUnitNotifier.value = _lengthUnitOptionsNotifier.value.first;
  }

  void _updateDimensions() {
    switch (_lengthUnitNotifier.value) {
      case .px:
        final displaySize = entries.first.displaySize;
        _widthController.text = '${displaySize.width.round()}';
        _heightController.text = '${displaySize.height.round()}';
      case .percent:
        _widthController.text = '100';
        _heightController.text = '100';
    }
  }

  @override
  void dispose() {
    _mimeTypeNotifier.dispose();
    _targetDimensionNotifier.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _lengthUnitOptionsNotifier.dispose();
    _lengthUnitNotifier.dispose();
    _isValidNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AvesDialog(
      scrollableContent: [
        const SizedBox(height: 16),
        if (_actionOptions.length > 1)
          Padding(
            padding: contentHorizontalPadding,
            child: ValueListenableBuilder<EntryConvertAction>(
              valueListenable: _actionNotifier,
              builder: (context, action, child) {
                return TextDropdownButton<EntryConvertAction>(
                  values: _actionOptions,
                  valueText: (v) => v.getText(context),
                  valueIcon: (v) => v.getIconData(),
                  value: action,
                  onChanged: (v) => _actionNotifier.value = v!,
                  isExpanded: true,
                  dropdownColor: Themes.thirdLayerColor(context),
                );
              },
            ),
          ),
        ValueListenableBuilder<EntryConvertAction>(
          valueListenable: _actionNotifier,
          builder: (context, action, child) {
            return AnimatedSwitcher(
              duration: context.read<DurationsData>().formTransition,
              switchInCurve: Curves.easeInOutCubic,
              switchOutCurve: Curves.easeInOutCubic,
              transitionBuilder: AvesTransitions.formTransitionBuilder,
              child: Column(
                key: ValueKey(action),
                mainAxisSize: .min,
                crossAxisAlignment: .stretch,
                children: [
                  if (action == .convert) ..._buildConvertContent(context),
                  if (action == .convertMotionPhotoToStillImage) const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ],
      actions: [
        const CancelButton(),
        ValueListenableBuilder<bool>(
          valueListenable: _isValidNotifier,
          builder: (context, isValid, child) {
            return TextButton(
              onPressed: isValid
                  ? () {
                      final options = EntryConvertOptions(
                        action: _actionNotifier.value,
                        mimeType: _mimeTypeNotifier.value,
                        targetDimension: _targetDimensionNotifier.value,
                        lengthUnit: _lengthUnitNotifier.value,
                        width: int.tryParse(_widthController.text),
                        height: int.tryParse(_heightController.text),
                        quality: _quality,
                        writeMetadata: _writeMetadata,
                      );

                      settings.convertMimeType = options.mimeType;
                      settings.convertQuality = options.quality;
                      settings.convertWriteMetadata = options.writeMetadata;

                      Navigator.maybeOf(context)?.pop<EntryConvertOptions>(options);
                    }
                  : null,
              child: Text(context.l10n.applyButtonLabel),
            );
          },
        ),
      ],
    );
  }

  // used by the drop down to match input decoration
  static Border _buildTextFieldDecorationBorder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Border(
      bottom: BorderSide(
        color: colorScheme.onSurface.withValues(alpha: .38),
        width: 1.0,
      ),
    );
  }

  List<Widget> _buildConvertContent(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return [
      Padding(
        padding: contentHorizontalPadding,
        child: Row(
          mainAxisSize: .min,
          children: [
            Text(l10n.exportEntryDialogFormat),
            const SizedBox(width: AvesDialog.controlCaptionPadding),
            ValueListenableBuilder<String>(
              valueListenable: _mimeTypeNotifier,
              builder: (context, mimeType, child) {
                return TextDropdownButton<String>(
                  values: _imageExportFormats,
                  valueText: MimeUtils.displayType,
                  value: mimeType,
                  onChanged: (v) => _mimeTypeNotifier.value = v!,
                );
              },
            ),
          ],
        ),
      ),
      if (!_sameSized)
        Padding(
          padding: contentHorizontalPadding,
          child: Row(
            mainAxisSize: .min,
            children: [
              Text(l10n.exportEntryDialogDimension),
              const SizedBox(width: AvesDialog.controlCaptionPadding),
              ValueListenableBuilder<ConvertDimension>(
                valueListenable: _targetDimensionNotifier,
                builder: (context, targetDimension, child) {
                  return TextDropdownButton<ConvertDimension>(
                    values: ConvertDimension.values,
                    valueText: (v) => v.getText(context),
                    value: targetDimension,
                    onChanged: (v) => _targetDimensionNotifier.value = v!,
                  );
                },
              ),
            ],
          ),
        ),
      _buildDimensionsRow(context),
      ValueListenableBuilder<String>(
        valueListenable: _mimeTypeNotifier,
        builder: (context, mimeType, child) {
          Widget child;
          if (_qualityFormats.contains(mimeType)) {
            child = SliderListTile(
              value: _quality.toDouble(),
              onChanged: (v) => setState(() => _quality = v.round()),
              min: 0,
              max: 100,
              title: (_) => l10n.exportEntryDialogQuality,
              titlePadding: contentHorizontalPadding,
              titleTrailing: (context, value) => ChangeHighlightText(
                TextSpan(text: '${value.round()}'),
                textStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                changeBlurRadius: 3,
                duration: context.read<DurationsData>().formTextStyleTransition,
              ),
            );
          } else {
            child = const SizedBox();
          }
          return AnimatedSwitcher(
            duration: context.read<DurationsData>().formTransition,
            switchInCurve: Curves.easeInOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            transitionBuilder: AvesTransitions.formTransitionBuilder,
            child: child,
          );
        },
      ),
      ValueListenableBuilder<String>(
        valueListenable: _mimeTypeNotifier,
        builder: (context, mimeType, child) {
          Widget child;
          if (AppSupport.canEditExif(mimeType) || AppSupport.canEditIptc(mimeType) || AppSupport.canEditXmp(mimeType)) {
            child = SwitchListTile(
              value: _writeMetadata,
              onChanged: (v) => setState(() => _writeMetadata = v),
              title: Text(l10n.exportEntryDialogWriteMetadata),
              contentPadding: const EdgeInsetsDirectional.only(
                start: AvesDialog.defaultHorizontalContentPadding,
                end: AvesDialog.defaultHorizontalContentPadding - 8,
              ),
            );
          } else {
            child = const SizedBox(height: 16);
          }
          return AnimatedSwitcher(
            duration: context.read<DurationsData>().formTransition,
            switchInCurve: Curves.easeInOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            transitionBuilder: AvesTransitions.formTransitionBuilder,
            child: child,
          );
        },
      ),
    ];
  }

  Widget _buildDimensionsRow(BuildContext context) {
    final l10n = context.l10n;

    final widthField = Expanded(
      child: TextField(
        controller: _widthController,
        decoration: InputDecoration(labelText: l10n.exportEntryDialogWidth),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          final width = int.tryParse(value);
          if (width != null) {
            switch (_lengthUnitNotifier.value) {
              case .px:
                _heightController.text = '${(width / entries.first.displayAspectRatio).round()}';
              case .percent:
                _heightController.text = '$width';
            }
          } else {
            _heightController.text = '';
          }
        },
      ),
    );

    final heightField = Expanded(
      child: TextField(
        controller: _heightController,
        decoration: InputDecoration(labelText: l10n.exportEntryDialogHeight),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          final height = int.tryParse(value);
          if (height != null) {
            switch (_lengthUnitNotifier.value) {
              case .px:
                _widthController.text = '${(height * entries.first.displayAspectRatio).round()}';
              case .percent:
                _widthController.text = '$height';
            }
          } else {
            _widthController.text = '';
          }
        },
      ),
    );

    final unitSelector = ValueListenableBuilder<List<LengthUnit>>(
      valueListenable: _lengthUnitOptionsNotifier,
      builder: (context, lengthUnitOptions, child) {
        return ValueListenableBuilder<LengthUnit>(
          valueListenable: _lengthUnitNotifier,
          builder: (context, lengthUnit, child) {
            return TextDropdownButton<LengthUnit>(
              values: lengthUnitOptions,
              valueText: (v) => v.getText(context),
              value: lengthUnit,
              onChanged: lengthUnitOptions.length > 1 ? (v) => _lengthUnitNotifier.value = v! : null,
              underline: Container(
                height: 1.0,
                decoration: BoxDecoration(
                  border: _buildTextFieldDecorationBorder(context),
                ),
              ),
              itemHeight: 60,
              dropdownColor: Themes.thirdLayerColor(context),
            );
          },
        );
      },
    );

    return Padding(
      padding: contentHorizontalPadding,
      child: ValueListenableBuilder<ConvertDimension>(
        valueListenable: _targetDimensionNotifier,
        builder: (context, targetDimension, child) {
          List<Widget> dimensionFields;
          switch (targetDimension) {
            case ConvertDimension.width:
              dimensionFields = [widthField];
            case ConvertDimension.height:
              dimensionFields = [heightField];
            case ConvertDimension.both:
              dimensionFields = [
                widthField,
                const SizedBox(width: 8),
                const Text(AText.resolutionSeparator),
                const SizedBox(width: 8),
                heightField,
              ];
          }

          return Row(
            crossAxisAlignment: .baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              ...dimensionFields,
              const SizedBox(width: 16),
              unitSelector,
            ],
          );
        },
      ),
    );
  }

  bool _areValidDimensions() {
    final targetDimension = _targetDimensionNotifier.value;
    final width = int.tryParse(_widthController.text);
    final height = int.tryParse(_heightController.text);
    final isValidWidth = targetDimension == .height || (width ?? 0) > 0;
    final isValidHeight = targetDimension == .width || (height ?? 0) > 0;
    return isValidWidth && isValidHeight;
  }

  void _validate() {
    switch (_actionNotifier.value) {
      case .convert:
        _isValidNotifier.value = _areValidDimensions();
      case .convertMotionPhotoToStillImage:
        _isValidNotifier.value = true;
    }
  }
}
