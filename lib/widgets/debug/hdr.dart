import 'package:aves/services/common/services.dart';
import 'package:aves/services/media/media_fetch_service.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:flutter/material.dart';

class DebugHdrSection extends StatefulWidget {
  const DebugHdrSection({super.key});

  @override
  State<DebugHdrSection> createState() => _DebugHdrSectionState();
}

class _DebugHdrSectionState extends State<DebugHdrSection> with AutomaticKeepAliveClientMixin {
  late Future<bool> _wideGamutModeLoader;
  late Future<bool> _hdrModeLoader;
  late Future<double?> _displayHdrSdrRatioLoader;
  late Future<double?> _hdrHeadroomLoader;

  @override
  void initState() {
    super.initState();
    _initLoaders();
  }

  void _initLoaders() {
    _wideGamutModeLoader = windowService.isInWideColorGamutMode();
    _hdrModeLoader = windowService.isInHdrMode();
    _displayHdrSdrRatioLoader = windowService.getDisplayHdrSdrRatio();
    _hdrHeadroomLoader = windowService.getDesiredHdrHeadroom();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AvesExpansionTile(
      title: 'HDR',
      children: [
        FutureBuilder<bool>(
          future: _wideGamutModeLoader,
          builder: (context, snapshot) {
            return SwitchListTile(
              value: snapshot.data ?? false,
              onChanged: (value) async {
                await windowService.setColorMode(wideColorGamut: value, hdr: false);
                _initLoaders();
                setState(() {});
              },
              title: const Text('Wide gamut mode'),
            );
          },
        ),
        FutureBuilder<bool>(
          future: _hdrModeLoader,
          builder: (context, hdrModeSnapshot) {
            final isHdrModeEnabled = hdrModeSnapshot.data ?? false;
            return FutureBuilder<double?>(
              future: _hdrHeadroomLoader,
              builder: (context, hdrHeadroomSnapshot) {
                final hdrHeadroom = hdrHeadroomSnapshot.data;
                return Column(
                  crossAxisAlignment: .start,
                  children: [
                    SwitchListTile(
                      value: isHdrModeEnabled,
                      onChanged: (value) async {
                        await windowService.setColorMode(wideColorGamut: false, hdr: value);
                        _initLoaders();
                        setState(() {});
                      },
                      title: FutureBuilder<double?>(
                        future: _displayHdrSdrRatioLoader,
                        builder: (context, hdrSdrRatioSnapshot) {
                          final hdrSdrRatio = hdrSdrRatioSnapshot.data;
                          return Text('HDR mode (ratio: $hdrSdrRatio)');
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text('Desired HDR headroom (current: ${hdrHeadroom?.round()})'),
                    ),
                    if (hdrHeadroom != null)
                      Slider(
                        value: hdrHeadroom,
                        onChanged: isHdrModeEnabled
                            ? (v) async {
                                await windowService.setColorMode(wideColorGamut: false, hdr: true, desiredHdrHeadroom: v);
                                _initLoaders();
                                setState(() {});
                              }
                            : null,
                        min: 0.0,
                        max: 10000.0,
                        label: '$hdrHeadroom',
                      ),
                    SwitchListTile(
                      value: PlatformMediaFetchService.applyHdrGainmap,
                      onChanged: (v) => setState(() => PlatformMediaFetchService.applyHdrGainmap = v),
                      title: const Text('Apply HDR gainmap'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
