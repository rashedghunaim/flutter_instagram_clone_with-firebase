import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_conditional_rendering/conditional.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:full_stack_instagram_clone/cash/cash_helper.dart';
import 'package:full_stack_instagram_clone/models/user_model.dart';
import 'package:full_stack_instagram_clone/modules/user_profile_module/Followers_Details_Screen.dart';
import 'package:full_stack_instagram_clone/modules/user_profile_module/user_post_details_screen.dart';
import 'package:full_stack_instagram_clone/shared/custom_shimmer_effect.dart';
import 'package:full_stack_instagram_clone/state_management/user_bloc/user_cubit.dart';
import 'package:full_stack_instagram_clone/state_management/user_bloc/user_cubit_states.dart';
import '../../shared/custom_page_route.dart';
import '../../shared/primary_button.dart';
import '../../shared/shared_functions.dart';
import 'package:cached_network_image/cached_network_image.dart';

// ignore: must_be_immutable
class UserProfileHeader extends StatefulWidget {
  final UserModel? user;
  final int userPostsLength;
  bool isFollowing;
  int followingLeng;
  int followersLeng;

  UserProfileHeader({
    required this.user,
    required this.userPostsLength,
    required this.followersLeng,
    required this.followingLeng,
    required this.isFollowing,
  });
  @override
  _UserProfileHeaderState createState() => _UserProfileHeaderState();
}

class _UserProfileHeaderState extends State<UserProfileHeader> {
  @override
  Widget build(BuildContext context) {
    final bool isCurrentModeDark =
        CashHelper.getSavedCashData(key: 'userLatestThemeMode');
    return BlocConsumer<UserCubit, UserStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 85,
                    height: 85,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: CachedNetworkImage(
                        imageUrl: widget.user!.profileImage.toString(),
                        fit: BoxFit.cover,
                        placeholder: (context, image) {
                          return customCircularShimmerEffect(
                            context: context,
                            height: 85,
                            width: 85,
                          );
                        },
                      ),
                    ),
                  ),
                  Container(
                    width: getDeviceWidth(context) * 0.60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              CustomPageRoute(
                                child: UserPostDetailsScreen(
                                  userID: widget.user!.uID,
                                ),
                                direction: AxisDirection.left,
                              ),
                            );
                          },
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${widget.userPostsLength.toString()}',
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Posts',
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2!
                                      .copyWith(
                                        fontWeight: FontWeight.normal,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              CustomPageRoute(
                                child: UserFollowingFollwersDetailsScreen(
                                  initialPage: 0,
                                  user: widget.user as UserModel,
                                ),
                                direction: AxisDirection.left,
                              ),
                            );
                          },
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${widget.followersLeng}',
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Followers',
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2!
                                      .copyWith(
                                        fontWeight: FontWeight.normal,
                                      ),
                                )
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              CustomPageRoute(
                                child: UserFollowingFollwersDetailsScreen(
                                  initialPage: 0,
                                  user: widget.user as UserModel,
                                ),
                                direction: AxisDirection.left,
                              ),
                            );
                          },
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${widget.followingLeng}',
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Following',
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2!
                                      .copyWith(
                                        fontWeight: FontWeight.normal,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.user!.userName}',
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  SizedBox(height: 5),
                  Text(
                    widget.user!.bio.toString(),
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                ],
              ),
            ),
            Conditional.single(
              context: context,
              conditionBuilder: (context) =>
                  widget.user!.uID ==
                  CashHelper.getSavedCashData(key: 'currentUserID'),
              widgetBuilder: (context) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  height: 35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(4),
                    ),
                    border: Border.all(
                      color: Colors.grey,
                      width: 0.5,
                    ),
                  ),
                  child: primaryButton(
                    isTitleUpperCase: false,
                    title: 'Edit profile',
                    hintStyle: Theme.of(context).textTheme.subtitle2!.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                    context: context,
                    overLayColor: isCurrentModeDark
                        ? Color(0xff17569b)
                        : Colors.grey[200],
                    backGroundColor: Colors.transparent,
                    titleColor: isCurrentModeDark ? Colors.white : Colors.black,
                    onTap: () {},
                  ),
                );
              },
              fallbackBuilder: (context) {
                return Conditional.single(
                  context: context,
                  conditionBuilder: (context) => widget.isFollowing,
                  widgetBuilder: (context) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 165,
                            height: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                              border: Border.all(
                                color: Colors.grey,
                                width: 0.5,
                              ),
                            ),
                            child: primaryButton(
                              overLayColor: Colors.grey,
                              isTitleUpperCase: false,
                              title: 'Unfollow',
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                              context: context,
                              backGroundColor: Colors.transparent,
                              titleColor: Colors.white,
                              onTap: () async {
                                UserCubit.getUserCubit(context).followingUser(
                                  followingUserID: widget.user!.uID.toString(),
                                );
                                setState(() {
                                  widget.isFollowing = false;
                                  widget.followersLeng--;
                                });
                              },
                            ),
                          ),
                          Container(
                            width: 165,
                            height: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                              border: Border.all(
                                color: Colors.grey,
                                width: 0.5,
                              ),
                            ),
                            child: primaryButton(
                              overLayColor: Colors.grey,
                              isTitleUpperCase: false,
                              title: 'Message',
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: isCurrentModeDark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                              context: context,
                              backGroundColor: Colors.transparent,
                              onTap: () {},
                            ),
                          ),
                          Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                              border: Border.all(
                                color: Colors.grey,
                                width: 0.5,
                              ),
                            ),
                            child: Center(
                              child: IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  FontAwesomeIcons.userPlus,
                                  size: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  fallbackBuilder: (context) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          primaryButton(
                            width: 165,
                            height: 35,
                            title: 'Follow',
                            hintStyle:
                                Theme.of(context).textTheme.subtitle2!.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                            context: context,
                            onTap: () async {
                              UserCubit.getUserCubit(context).followingUser(
                                followingUserID: widget.user!.uID.toString(),
                              );
                              setState(() {
                                widget.isFollowing = true;
                                widget.followersLeng++;
                              });
                            },
                          ),
                          Container(
                            width: 165,
                            height: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                              border: Border.all(
                                color: Colors.grey,
                                width: 0.5,
                              ),
                            ),
                            child: primaryButton(
                              overLayColor: Colors.grey,
                              isTitleUpperCase: false,
                              title: 'Message',
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                              context: context,
                              backGroundColor: Colors.transparent,
                              titleColor: Colors.white,
                              onTap: () {},
                            ),
                          ),
                          Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                              border: Border.all(
                                color: Colors.grey,
                                width: 0.5,
                              ),
                            ),
                            child: Center(
                              child: IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  FontAwesomeIcons.userPlus,
                                  size: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}
