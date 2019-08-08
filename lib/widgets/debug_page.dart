import 'package:aves/model/image_entry.dart';
import 'package:aves/model/metadata_storage_service.dart';
import 'package:flutter/material.dart';

class DebugPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DebugPageState();
}

class DebugPageState extends State<DebugPage> {
  Future<List<CatalogMetadata>> _dbLoader;

  @override
  void initState() {
    super.initState();
    _dbLoader = metadataDb.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Info'),
      ),
      body: Column(
        children: [
          RaisedButton(
            onPressed: () => metadataDb.reset(),
            child: Text('Reset DB'),
          ),
          Expanded(
            child: FutureBuilder(
              future: _dbLoader,
              builder: (futureContext, AsyncSnapshot<List<CatalogMetadata>> snapshot) {
                if (snapshot.hasError) return Text(snapshot.error);
                if (snapshot.connectionState != ConnectionState.done)
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                final metadata = snapshot.data;
                return ListView.builder(
                  itemBuilder: (context, index) => Text('    $index: ${metadata[index]}'),
                  itemCount: metadata.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
