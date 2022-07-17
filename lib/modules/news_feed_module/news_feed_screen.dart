import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:full_stack_instagram_clone/models/story_model.dart';
import 'package:full_stack_instagram_clone/modules/news_feed_module/user_post_item.dart';
import 'package:full_stack_instagram_clone/shared/data.dart';
import 'package:full_stack_instagram_clone/shared/shared_functions.dart';
import 'package:full_stack_instagram_clone/state_management/layout_bloc/home_layout_cubit.dart';
import 'package:full_stack_instagram_clone/state_management/layout_bloc/layout_states.dart';
import 'package:full_stack_instagram_clone/state_management/user_bloc/user_cubit.dart';
import 'package:full_stack_instagram_clone/state_management/user_bloc/user_cubit_states.dart';
import 'package:full_stack_instagram_clone/util/global_variables.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import '../../cash/cash_helper.dart';
import 'current_user_story_button.dart';
import 'story_button_item.dart';

class NewsFeedScreen extends StatefulWidget {
  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  Future<void> triggerStraem() async {
    UserCubit.getUserCubit(context).markNeedToReBuild();
  }

  bool done = true;


  @override
  Widget build(BuildContext context) {
    bool isCurrentModeDark = CashHelper.getSavedCashData(
      key: 'userLatestThemeMode',
    );
    return Scaffold(
      appBar: AppBar(
        title: BlocConsumer<LayoutCubit, LayoutStates>(
          listener: (context, state) {},
          builder: (context, state) {
            bool isCurrentModeDark = CashHelper.getSavedCashData(
              key: 'userLatestThemeMode',
            );
            if (state is SwitchThemeModeState) {
              isCurrentModeDark = state.isDarkMode;
            }
            return SvgPicture.asset(
              'lib/assets/images/ic_instagram.svg',
              height: 30,
              width: 30,
              color: isCurrentModeDark ? Colors.white : Colors.black,
            );
          },
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              onPressed: () {},
              icon: FaIcon(
                FontAwesomeIcons.facebookMessenger,
              ),
            ),
          ),
        ],
      ),
      body: LiquidPullToRefresh(
        color: isCurrentModeDark ? Colors.grey[800] : Colors.grey[200],
        showChildOpacityTransition: false,
        animSpeedFactor: 10.0,
        backgroundColor:
            isCurrentModeDark ? Colors.grey[200] : Colors.grey[800],
        onRefresh: triggerStraem,
        child: StreamBuilder(
          stream: GlobalV.firestore.collection('userPosts').snapshots(),
          builder: (
            BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapShot,
          ) {
            if (snapShot.connectionState == ConnectionState.waiting) {
              return Center(
                child: isCurrentModeDark
                    ? CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 0.3,
                      )
                    : CircularProgressIndicator(
                        color: Colors.grey[600],
                        strokeWidth: 0.6,
                      ),
              );
            }

            return BlocConsumer<UserCubit, UserStates>(
              bloc: UserCubit.getUserCubit(context),
              listener: (context, state) {},
              builder: (context, state) {
                return ListView(
                  physics: BouncingScrollPhysics(),
                  children: [
                    Container(
                      height: getDeviceHeight(context) * 0.12,
                      width: double.infinity,
                      child: ListView(
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        children: [
                          CurrentUserStoryButton(),
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              
                              return StoryButtonItem(
                                userName: 'rashed',
                                userProfileImage:
                                    'https://i.pinimg.com/236x/4c/76/71/4c76710890304cff99c2b58acb1a18a9.jpg',
                              );
                            },
                            itemCount: dummyStories.length,
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return UserPostItem(
                          snapShot.data!.docs[index].data(),
                        );
                      },
                      itemCount: snapShot.data!.docs.length,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
