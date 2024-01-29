import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:aptabase_flutter/aptabase_flutter.dart';


class Navigationbar extends StatefulWidget {
  final int initialIndex;
  const Navigationbar({Key? key, required this.initialIndex}) : super(key: key);

  @override
  State<Navigationbar> createState() => _NavBuilder();
}

class _NavBuilder extends State<Navigationbar> {
  int _selectedIndex = 0;
  bool _mounted = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _mounted = true;
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).bottomAppBarTheme.surfaceTintColor?.withOpacity(0.8),
          borderRadius: const BorderRadius.all( Radius.circular(25), )
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
          child: GNav(
            onTabChange: (index) {
              if (_mounted) {
                setState(() {
                  _selectedIndex = index;
                });
    
                String currentRoute = ModalRoute.of(context)!.settings.name ?? '';
                String desiredRoute = '';
    
                if (index == 0) {
                  desiredRoute = '/home/feed';
                } else if (index == 1) {
                  desiredRoute = '/home/message';
                } else if (index == 2) {
                  desiredRoute = '/home/start';
                } else if (index == 3) {
                  desiredRoute = '/home/friends';
                } else if (index == 4) {
                  desiredRoute = '/home/news';
                }
    
                Aptabase.instance.trackEvent("switchPage", { "page": desiredRoute });
    
                if (currentRoute == '/home/start') {
                  Navigator.pushReplacementNamed(context, desiredRoute);
                } else {
                  Navigator.pushNamed(context, desiredRoute);
                }
              }
            },
            gap: 8,
            backgroundColor: Theme.of(context).bottomAppBarTheme.surfaceTintColor!,
            color: Theme.of(context).bottomAppBarTheme.color!,
            activeColor: Theme.of(context).bottomAppBarTheme.shadowColor!,
            tabBackgroundColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.all(16),
            tabs: const [
              GButton(
                icon: FeatherIcons.activity,
                text: 'Overzicht',
              ),
              GButton(
                icon: FeatherIcons.messageCircle,
                text: 'Gesprekken',
              ),
              GButton(
                icon: FeatherIcons.camera,
                text: 'Camera',
              ),
              GButton(
                icon: FeatherIcons.heart,
                text: 'Vrienden',
              ),
              GButton(
                icon: FeatherIcons.anchor,
                text: 'Nieuws',
              ),
            ],
            selectedIndex: _selectedIndex,
          ),
        ),
      ),
    );
    duration: Duration.zero;
  }
}
