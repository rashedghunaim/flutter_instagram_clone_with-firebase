import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'layout_states.dart';

class LayoutCubit extends Cubit<LayoutStates> {
  LayoutCubit(LayoutStates initialState) : super(initialState);

  static LayoutCubit getLayoutCubit(BuildContext context) {
    return BlocProvider.of<LayoutCubit>(context);
  }

  List<PersistentBottomNavBarItem> getBarItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.home_filled),
        activeColorPrimary: Colors.black,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(
          Icons.search,
        ),
        activeColorPrimary: Colors.black,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.add_circle),
        activeColorPrimary: Colors.black,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.favorite),
        activeColorPrimary: Colors.black,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.account_circle_rounded),
        activeColorPrimary: Colors.black,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  void switchThemeMode({required bool isDarkMode}) {
    emit(SwitchThemeModeState(
      isDarkMode: isDarkMode,
    ));
  }
}
