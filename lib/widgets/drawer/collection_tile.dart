import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CollectionNavTile extends StatelessWidget {
  final Widget? leading;
  final String title;
  final Widget? trailing;
  final bool dense;
  final CollectionFilter? filter;

  const CollectionNavTile({
    required this.leading,
    required this.title,
    this.trailing,
    bool? dense,
    required this.filter,
  }) : dense = dense ?? false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: ListTile(
        leading: leading,
        title: Text(title),
        trailing: trailing,
        dense: dense,
        onTap: () => _goToCollection(context),
      ),
    );
  }

  void _goToCollection(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: CollectionPage.routeName),
        builder: (context) => CollectionPage(CollectionLens(
          source: context.read<CollectionSource>(),
          filters: [filter],
        )),
      ),
      (route) => false,
    );
  }
}
