import 'package:aves/model/image_entry.dart';
import 'package:aves/model/image_fetcher.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FullscreenOverlay extends StatefulWidget {
  final List<Map> entries;
  final int index;

  const FullscreenOverlay({Key key, this.entries, this.index}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FullscreenOverlayState();
}

class _FullscreenOverlayState extends State<FullscreenOverlay> {
  Future<Map> _detailLoader;
  Map _lastDetails;

  Map get entry => widget.entries[widget.index];

  int get total => widget.entries.length;

  @override
  void initState() {
    super.initState();
    initDetailLoader();
  }

  @override
  void didUpdateWidget(FullscreenOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    initDetailLoader();
  }

  initDetailLoader() {
    _detailLoader = ImageFetcher.getOverlayMetadata(entry['path']);
  }

  @override
  Widget build(BuildContext context) {
    var viewInsets = MediaQuery.of(context).viewInsets;
    var date = ImageEntry.getBestDate(entry);
    var subRowConstraints = BoxConstraints(maxWidth: 400);
    return IgnorePointer(
      child: Container(
        padding: EdgeInsets.all(8.0).add(EdgeInsets.only(bottom: viewInsets.bottom)),
        color: Colors.black45,
        child: DefaultTextStyle(
          style: TextStyle(
            shadows: [
              Shadow(
                color: Colors.black87,
                offset: Offset(0.0, 1.0),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.index + 1}/$total – ${entry['title']}',
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              ConstrainedBox(
                constraints: subRowConstraints,
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16),
                    SizedBox(width: 8),
                    Expanded(child: Text('${DateFormat.yMMMd().format(date)} – ${DateFormat.Hm().format(date)}')),
                    Expanded(child: Text('${entry['width']} × ${entry['height']}')),
                  ],
                ),
              ),
              SizedBox(height: 4),
              FutureBuilder(
                future: _detailLoader,
                builder: (futureContext, AsyncSnapshot<Map> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && !snapshot.hasError) {
                    _lastDetails = snapshot.data;
                  }
                  return (_lastDetails == null || _lastDetails.isEmpty)
                      ? Text('')
                      : ConstrainedBox(
                          constraints: subRowConstraints,
                          child: Row(
                            children: [
                              Icon(Icons.camera, size: 16),
                              SizedBox(width: 8),
                              Expanded(child: Text((_lastDetails['aperture'] as String).replaceAll('f', 'ƒ'))),
                              Expanded(child: Text(_lastDetails['exposureTime'])),
                              Expanded(child: Text(_lastDetails['focalLength'])),
                              Expanded(child: Text(_lastDetails['iso'])),
                            ],
                          ),
                        );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
