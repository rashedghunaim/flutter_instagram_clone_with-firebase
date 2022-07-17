import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:full_stack_instagram_clone/cash/cash_helper.dart';
import 'package:full_stack_instagram_clone/models/user_model.dart';
import 'package:full_stack_instagram_clone/modules/user_profile_module/user_following_item.dart';
import 'package:full_stack_instagram_clone/state_management/user_bloc/user_cubit.dart';
import 'package:full_stack_instagram_clone/state_management/user_bloc/user_cubit_states.dart';

import '../../shared/primary_InputField.dart';
import 'user_follower_item.dart';

class UserFollowingFollwersDetailsScreen extends StatefulWidget {
  final UserModel user;
  final int initialPage;
  UserFollowingFollwersDetailsScreen({
    required this.initialPage,
    required this.user,
  });
  static const routeName = './User_Following_Details_screen';

  @override
  State<UserFollowingFollwersDetailsScreen> createState() =>
      _UserFollowingFollwersDetailsScreenState();
}

class _UserFollowingFollwersDetailsScreenState
    extends State<UserFollowingFollwersDetailsScreen> {
  final _searchController = TextEditingController();
  final scrollPhysics = ScrollPhysics();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool isFollowing = false;
  @override
  Widget build(BuildContext context) {
    if (widget.user.uID == CashHelper.getSavedCashData(key: 'currentUserID')) {
      isFollowing = true;
    } else {
      isFollowing = widget.user.followers!.contains(
        CashHelper.getSavedCashData(key: 'currentUserID'),
      );
    }

    // bool isFollowing = widget.user.followers!.contains(
    // CashHelper.getSavedCashData(key: 'currentUserID'),);

    final bool isCurrentModeDark =
        CashHelper.getSavedCashData(key: 'userLatestThemeMode');

    final userCubit = UserCubit.getUserCubit(context);
    return DefaultTabController(
      initialIndex: widget.initialPage,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('mohammad'),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 35),
                  child: Divider(
                    height: 20,
                    color: Colors.grey,
                    thickness: 0.2,
                    endIndent: 15,
                    indent: 15,
                  ),
                ),
                BlocConsumer<UserCubit, UserStates>(
                  listener: (context, state) {},
                  builder: (context, state) {
                    return TabBar(
                      indicatorColor:
                          isCurrentModeDark ? Colors.white : Colors.black,
                      indicatorWeight: 0.5,
                      indicatorSize: TabBarIndicatorSize.tab,
                      physics: BouncingScrollPhysics(),
                      onTap: (index) {
                        userCubit.toggleFollowersPageView(index);
                      },
                      tabs: [
                        Tab(
                          child: Text(
                            '${widget.user.followers!.length} followers',
                            style:
                                Theme.of(context).textTheme.subtitle2!.copyWith(
                                      color: userCubit.selectedIndex == 0
                                          ? isCurrentModeDark
                                              ? Colors.white
                                              : Colors.black
                                          : Colors.grey,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ),
                        Tab(
                          child: Text(
                            '${widget.user.following!.length} following',
                            style:
                                Theme.of(context).textTheme.subtitle2!.copyWith(
                                      color: userCubit.selectedIndex == 1
                                          ? isCurrentModeDark
                                              ? Colors.white
                                              : Colors.black
                                          : Colors.grey,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        )
                      ],
                    );
                  },
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFF333333),
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: primaryInputField(
                autoFocusKeyboard: false,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                focusBorder:
                    Theme.of(context).inputDecorationTheme.focusedBorder,
                enabledBorder:
                    Theme.of(context).inputDecorationTheme.enabledBorder,
                context: context,
                controller: _searchController,
                hintText: 'search',
                contentPadding: EdgeInsets.only(top: 5, left: 15),
                prefixIcon: Icon(Icons.search),
                onFieldSubmitted: (value) {},
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                physics: BouncingScrollPhysics(),
                children: [
                  ListView.builder(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return UserFollowerItem(
                        userName: widget.user.userName,
                        isFollowing: isFollowing,
                        userID: widget.user.followers![index],
                      );
                    },
                    itemCount: widget.user.followers!.length,
                  ),
                  ListView.builder(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return FollowingUserItem(
                        userName: widget.user.userName.toString(),
                        isFollowing: isFollowing,
                        userID: widget.user.following![index],
                      );
                    },
                    itemCount: widget.user.following!.length,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
