// lib/screens/home_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemNavigator;

import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/screens/call_history_screen.dart';
import 'package:smart_contacts_dialer/screens/contact_list_screen.dart';
import 'package:smart_contacts_dialer/screens/dialer_screen.dart';
import 'package:smart_contacts_dialer/screens/tag_cloud_screen.dart';

/// App shell hosting the three primary destinations behind a compact custom
/// bottom bar: Contacts, Dialer and Recents. Makes the dialer first-class
/// without changing the contacts screen's internals.
///
/// An [IndexedStack] keeps each tab's state alive across switches; the bar is
/// themed from the same [AppColors] tokens as the rest of the app so the tabs
/// read as one product. See [_navItem] for why a custom bar replaced the
/// Material [NavigationBar].
///
/// The body also owns the main-screen swipe gestures: a left fling cycles the
/// tabs (wrapping back to the first), a right fling twice within
/// [_exitWindow] leaves the app. Being *inside* the tab body, this detector
/// wins over the root back-swipe in `main.dart` whenever the shell is the
/// visible route.
class HomeShell extends StatefulWidget {
  final bool addCallMode;
  final int initialIndex;

  const HomeShell({
    super.key,
    this.addCallMode = false,
    this.initialIndex = 0,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _index;

  /// Index of the Dialer destination within [_tabs] / the nav bar.
  static const _dialerIndex = 1;

  /// Index of the Recents destination within [_tabs] / the nav bar.
  static const _recentsIndex = 2;

  /// Index of the Tags (tag cloud) destination within [_tabs] / the nav bar.
  static const _tagsIndex = 3;

  /// Lets [build] reach the live Dialer screen (kept alive by the
  /// [IndexedStack]) so its Favorites / Top-contacts lists can be reloaded when
  /// the tab is selected — stars/scores may have changed on another tab.
  final _dialerKey = GlobalKey<DialerScreenState>();

  /// Lets [build] reach the live Recents screen (kept alive by the
  /// [IndexedStack]) so it can be reloaded when the tab is selected.
  final _recentsKey = GlobalKey<CallHistoryScreenState>();

  /// Lets [build] reach the live Tags screen (kept alive by the [IndexedStack])
  /// so its tag cloud can be reloaded when the tab is selected — tags may have
  /// changed while editing a contact on another tab.
  final _tagsKey = GlobalKey<TagCloudScreenState>();

  late final List<Widget> _tabs = [
    const ContactListScreen(),
    DialerScreen(key: _dialerKey, addCallMode: widget.addCallMode),
    CallHistoryScreen(key: _recentsKey),
    TagCloudScreen(key: _tagsKey),
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  void _onSelect(int i) {
    setState(() => _index = i);
    // These tabs only load once (IndexedStack keeps them alive), so changes made
    // on another tab won't show until we re-query on selection.
    if (i == _dialerIndex) {
      _dialerKey.currentState?.reload();
    } else if (i == _recentsIndex) {
      _recentsKey.currentState?.reload();
    } else if (i == _tagsIndex) {
      _tagsKey.currentState?.reload();
    }
  }

  /// How fast a horizontal drag must end (logical px/s) to count as a swipe.
  /// High enough that list scrolls that drift sideways don't trigger it.
  static const double _swipeVelocity = 300;

  /// Second right-swipe within this window exits the app.
  static const Duration _exitWindow = Duration(seconds: 2);

  DateTime? _lastExitSwipe;

  void _onHorizontalDragEnd(DragEndDetails details) {
    final v = details.primaryVelocity ?? 0;
    if (v <= -_swipeVelocity) {
      // Swipe left → next tab, wrapping around after the last one.
      _onSelect((_index + 1) % _tabs.length);
    } else if (v >= _swipeVelocity) {
      _onExitSwipe();
    }
  }

  /// First right-swipe warns, a second within [_exitWindow] exits. Mirrors the
  /// common double-back-to-exit pattern so a stray swipe never quits the app.
  void _onExitSwipe() {
    final now = DateTime.now();
    final last = _lastExitSwipe;
    if (last != null && now.difference(last) <= _exitWindow) {
      SystemNavigator.pop();
      return;
    }
    _lastExitSwipe = now;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Swipe right again to exit'),
          duration: _exitWindow,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;

    final bodyWidget = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: IndexedStack(index: _index, children: _tabs),
    );

    // A custom bottom bar rather than the Material [NavigationBar]: the stock
    // widget centers only the icon and hangs the label below it on unselected
    // tabs, which at a compact height leaves a gap above the icons and presses
    // the labels against the bottom edge. Here every tab centers the icon+label
    // as one tight group, so the top/bottom margins stay small and even. The
    // pill indicator + AppColors theming are kept so it reads the same.
    return Scaffold(
      body: widget.addCallMode
          ? Column(
              children: [
                Material(
                  color: colors.cardSurface,
                  elevation: 2,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () {
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              }
                            },
                            tooltip: 'Return to call',
                          ),
                          const SizedBox(width: 4),
                          const Expanded(
                            child: Text(
                              'Adding call to ongoing call…',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(child: bodyWidget),
              ],
            )
          : bodyWidget,
      bottomNavigationBar: Material(
        color: colors.cardSurface,
        child: SafeArea(
          top: false,
          // Small, even padding above the icons and below the labels (the extra
          // bottom pad also gives the labels breathing room over the gesture
          // pill).
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 6, 0, 8),
            child: Row(
              children: [
                _navItem(
                  colors,
                  accent,
                  index: 0,
                  icon: Icons.people_outline,
                  selectedIcon: Icons.people,
                  label: 'Contacts',
                ),
                _navItem(
                  colors,
                  accent,
                  index: _dialerIndex,
                  icon: Icons.dialpad,
                  selectedIcon: Icons.dialpad,
                  label: 'Dialer',
                ),
                _navItem(
                  colors,
                  accent,
                  index: _recentsIndex,
                  icon: Icons.history,
                  selectedIcon: Icons.history,
                  label: 'Recents',
                ),
                _navItem(
                  colors,
                  accent,
                  index: _tagsIndex,
                  icon: Icons.sell_outlined,
                  selectedIcon: Icons.sell,
                  label: 'Tags',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// One destination in the custom bottom bar: a pill-wrapped icon over its
  /// label, both centered as a group and tinted by selection state.
  Widget _navItem(
    AppColors colors,
    Color accent, {
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final selected = _index == index;
    final tint = selected ? accent : colors.mutedText;
    return Expanded(
      child: InkResponse(
        onTap: () => _onSelect(index),
        radius: 48,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? accent.withValues(alpha: 0.16)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                selected ? selectedIcon : icon,
                size: 22,
                color: tint,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: tint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
