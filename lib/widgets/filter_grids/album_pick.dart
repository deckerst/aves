import 'package:aves/utils/debouncer.dart';
import 'package:aves/utils/durations.dart';
import 'package:aves/widgets/common/action_delegates/create_album_dialog.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/filter_grids/common/chip_actions.dart';
import 'package:aves/widgets/filter_grids/common/chip_set_action_delegate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AlbumPickAppBar extends StatelessWidget {
  final bool copy;
  final AlbumChipSetActionDelegate actionDelegate;
  final ValueChanged<String> onFilterChanged;

  const AlbumPickAppBar({
    @required this.copy,
    @required this.actionDelegate,
    @required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      leading: BackButton(),
      title: Text(copy ? 'Copy to Album' : 'Move to Album'),
      bottom: AlbumFilterBar(
        onChanged: onFilterChanged,
      ),
      actions: [
        IconButton(
          icon: Icon(AIcons.createAlbum),
          onPressed: () async {
            final newAlbum = await showDialog<String>(
              context: context,
              builder: (context) => CreateAlbumDialog(),
            );
            if (newAlbum != null && newAlbum.isNotEmpty) {
              Navigator.pop<String>(context, newAlbum);
            }
          },
          tooltip: 'Create album',
        ),
        IconButton(
          icon: Icon(AIcons.sort),
          onPressed: () => actionDelegate.onActionSelected(context, ChipSetAction.sort),
        ),
      ],
      floating: true,
    );
  }
}

class AlbumFilterBar extends StatefulWidget implements PreferredSizeWidget {
  final ValueChanged<String> onChanged;

  const AlbumFilterBar({@required this.onChanged});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  _AlbumFilterBarState createState() => _AlbumFilterBarState();
}

class _AlbumFilterBarState extends State<AlbumFilterBar> {
  final TextEditingController _controller = TextEditingController(text: '');
  final Debouncer _debouncer = Debouncer(delay: Durations.searchDebounceDelay);

  @override
  Widget build(BuildContext context) {
    final clearButton = IconButton(
      icon: Icon(AIcons.clear),
      onPressed: () {
        _controller.clear();
        widget.onChanged('');
      },
      tooltip: 'Clear',
    );
    return Container(
      height: kToolbarHeight,
      alignment: Alignment.topCenter,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon(AIcons.search),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                icon: Padding(
                  padding: EdgeInsetsDirectional.only(start: 16),
                  child: Icon(AIcons.search),
                ),
                // border: OutlineInputBorder(),
                hintText: MaterialLocalizations.of(context).searchFieldLabel,
                hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
              ),
              textInputAction: TextInputAction.search,
              onChanged: (s) => _debouncer(() => widget.onChanged(s)),
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => AnimatedSwitcher(
              duration: Durations.appBarActionChangeAnimation,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  axis: Axis.horizontal,
                  sizeFactor: animation,
                  child: child,
                ),
              ),
              child: _controller.text.isNotEmpty ? clearButton : SizedBox(width: 16),
            ),
          )
        ],
      ),
    );
  }
}
