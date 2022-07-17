import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:full_stack_instagram_clone/shared/data.dart';
import 'package:full_stack_instagram_clone/state_management/layout_bloc/home_layout_cubit.dart';
import 'package:full_stack_instagram_clone/state_management/layout_bloc/layout_states.dart';
import 'package:full_stack_instagram_clone/state_management/user_bloc/user_cubit.dart';
import 'package:full_stack_instagram_clone/modules/user_profile_module/user_profile_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import '../../modules/news_feed_module/news_feed_screen.dart';
import '../modules/add_new_post_screen.dart';
import '../modules/explore_module/explore_screen.dart';
import '../state_management/user_bloc/user_cubit_states.dart';

class MobileHomeScreenLayout extends StatefulWidget {
  static const String routeName = './MobileScreenHomeLayout';

  @override
  State<MobileHomeScreenLayout> createState() => _MobileHomeScreenLayoutState();
}

class _MobileHomeScreenLayoutState extends State<MobileHomeScreenLayout> {
  PersistentTabController presController = PersistentTabController();

  @override
  void initState() {
    presController = PersistentTabController(initialIndex: 0);
    super.initState();
  }

  @override
  void dispose() {
    presController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LayoutCubit, LayoutStates>(
      listener: (context, state) {},
      builder: (context, state) {
        List<Widget> homeLayoutScreens = [
          NewsFeedScreen(),
          ExploreScreen(),
          AddNewPostScreen(),
          Container(
            child: Center(
              child: Text('favoruites screen'),
            ),
          ),
          BlocConsumer<UserCubit, UserStates>(
            listener: (context, state) {},
            builder: (context, state) {
              return UserProfileScreen(
                userID:
                    UserCubit.getUserCubit(context).currentUser.uID.toString(),
                appBarUserName: state is FetchUserDocumentDataSuccessState
                    ? state.user.userName.toString()
                    : '',
              );
            },
          ),
        ];
        final homeLayoutCubit = LayoutCubit.getLayoutCubit(context);
        return Scaffold(
          body: BlocConsumer<UserCubit, UserStates>(
            listener: (context, state) {},
            builder: (context, state) {
              bool hidePersistentTabView = false;
              if (state is UserSignOutSuccessState) {
                hidePersistentTabView = state.hidePersistentTabView;
              } else if (state is HidePresistenceTableViewState) {
                hidePersistentTabView = state.hidePersistentTabView;
              }
              return PersistentTabView(
                context,
                navBarHeight: 50,
                hideNavigationBar: hidePersistentTabView,
                selectedTabScreenContext: (context) {},
                controller: presController,
                screens: homeLayoutScreens,
                items: homeLayoutCubit.getBarItems(),
                confineInSafeArea: true,
                resizeToAvoidBottomInset: true,
                hideNavigationBarWhenKeyboardShows: true,
                popAllScreensOnTapOfSelectedTab: true,
                popActionScreens: PopActionScreensType.all,
                itemAnimationProperties: ItemAnimationProperties(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.ease,
                ),
                screenTransitionAnimation: ScreenTransitionAnimation(),
                navBarStyle: NavBarStyle.style12,
                decoration: NavBarDecoration(
                  adjustScreenBottomPaddingOnCurve: true,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      spreadRadius: 0.1,
                    ),
                  ],
                ),
                onItemSelected: (selectedIndex) {},
                stateManagement: true,
              );
            },
          ),
        );
      },
    );
  }
}
