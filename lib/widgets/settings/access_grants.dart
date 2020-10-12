import 'package:aves/services/android_file_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GrantedDirectories extends StatefulWidget {
  @override
  _GrantedDirectoriesState createState() => _GrantedDirectoriesState();
}

class _GrantedDirectoriesState extends State<GrantedDirectories> {
  Future<List<String>> _pathLoader;
  List<String> _lastPaths;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _pathLoader = AndroidFileService.getGrantedDirectories();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: FutureBuilder<List<String>>(
        future: _pathLoader,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (snapshot.connectionState != ConnectionState.done && _lastPaths == null) {
            return SizedBox.shrink();
          }
          _lastPaths = snapshot.data..sort();
          final count = _lastPaths.length;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aves has access to ${Intl.plural(count, zero: 'no directories.', one: 'one directory:', other: '$count directories:')}',
                style: textTheme.subtitle1,
              ),
              ..._lastPaths.map((path) => Row(
                    children: [
                      Expanded(child: Text(path, style: textTheme.caption)),
                      SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () async {
                          await AndroidFileService.revokeDirectoryAccess(path);
                          _load();
                          setState(() {});
                        },
                        child: Text('Revoke'.toUpperCase()),
                      ),
                    ],
                  )),
            ],
          );
        },
      ),
    );
  }
}
