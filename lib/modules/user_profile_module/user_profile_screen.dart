import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_conditional_rendering/conditional.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:full_stack_instagram_clone/models/user_model.dart';
import 'package:full_stack_instagram_clone/models/user_post_model.dart';
import 'package:full_stack_instagram_clone/modules/user_profile_module/user_post_details_screen.dart';
import 'package:full_stack_instagram_clone/modules/user_profile_module/user_profile_header.dart';
import 'package:full_stack_instagram_clone/shared/custom_shimmer_effect.dart';
import 'package:full_stack_instagram_clone/state_management/layout_bloc/home_layout_cubit.dart';
import 'package:full_stack_instagram_clone/state_management/user_bloc/user_cubit.dart';
import 'package:full_stack_instagram_clone/util/global_variables.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import '../../cash/cash_helper.dart';
import '../../shared/custom_page_route.dart';
import '../../shared/primary_button.dart';
import '../../shared/shared_functions.dart';
import '../login_screen.dart';

class UserProfileScreen extends StatefulWidget {
  static const routeName = './UserProfileScreen';
  final String userID;
  final String appBarUserName;
  UserProfileScreen({
    required this.appBarUserName,
    required this.userID,
  });
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  UserModel? user = UserModel.getJson({});
  bool isLoading = true;
  int postLeng = 0;
  int followersLeng = 0;
  int followingLeng = 0;
  bool isFollowing = false;
  @override
  void initState() {
    getUserProfile();
    super.initState();
  }

  Future<void> getUserProfile() async {
    try {
      var snapShot =
          await GlobalV.firestore.collection('users').doc(widget.userID).get();

      user = UserModel.getJson(
        snapShot.data()!,
      );

      QuerySnapshot<Map<String, dynamic>> postSnap = await GlobalV.firestore
          .collection('userPosts')
          .where(
            'uID',
            isEqualTo: widget.userID,
          )
          .get();
      postLeng = postSnap.docs.length;
      followersLeng = snapShot.data()!['followers'].length;
      followingLeng = snapShot.data()!['following'].length;
      isFollowing = snapShot.data()!['followers'].contains(
            UserCubit.getUserCubit(context).currentUser.uID,
          );

      setState(() {
        isLoading = false;
      });
    } catch (error) {
      print(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isCurrentModeDark =
        CashHelper.getSavedCashData(key: 'userLatestThemeMode');
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(widget.appBarUserName.toString()),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () async {
                await openRightSideBottomSheet();
              },
              icon: Icon(FontAwesomeIcons.bars),
            ),
          )
        ],
      ),
      body: Conditional.single(
        context: context,
        conditionBuilder: (context) => isLoading,
        widgetBuilder: (context) {
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
        },
        fallbackBuilder: (context) {
          return LiquidPullToRefresh(
            color: isCurrentModeDark ? Colors.grey[800] : Colors.grey[200],
            showChildOpacityTransition: false,
            animSpeedFactor: 10.0,
            backgroundColor:
                isCurrentModeDark ? Colors.grey[200] : Colors.grey[800],
            onRefresh: getUserProfile,
            child: ListView(
              shrinkWrap: true,
              children: [
                UserProfileHeader(
                  user: user,
                  userPostsLength: postLeng,
                  isFollowing: isFollowing,
                  followersLeng: followersLeng,
                  followingLeng: followingLeng,
                ),
                Container(
                  child: FutureBuilder(
                    future: GlobalV.firestore
                        .collection('userPosts')
                        .where('uID', isEqualTo: widget.userID)
                        .get(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                            snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return customProgressIndecator();
                      }
                      return GridView.builder(
                        physics: BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 1.5,
                          childAspectRatio: 1,
                        ),
                        shrinkWrap: true,
                        itemCount: (snapshot.data! as dynamic).docs.length,
                        itemBuilder: (context, index) {
                          UserPostModel post = UserPostModel.getJson(
                            snapshot.data!.docs[index].data(),
                          );

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                CustomPageRoute(
                                  child: UserPostDetailsScreen(
                                    userID: widget.userID,
                                  ),
                                  direction: AxisDirection.left,
                                ),
                              );
                            },
                            child: Container(
                              child: CachedNetworkImage(
                                imageUrl: post.postPhotoUrl.toString(),
                                fit: BoxFit.cover,
                                placeholder: (context, image) {
                                  return Center(
                                    child: isCurrentModeDark
                                        ? customRectangleShimmerEffect(
                                            context: context,
                                            height: double.infinity,
                                            width: double.infinity,
                                          )
                                        : customRectangleShimmerEffect(
                                            context: context,
                                            height: double.infinity,
                                            width: double.infinity,
                                          ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> openRightSideBottomSheet() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 15),
                width: 40,
                height: 3,
                color: Colors.white70,
              ),
              Container(
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
                  overLayColor: Colors.grey,
                  isTitleUpperCase: false,
                  title: 'Sign Out',
                  hintStyle: Theme.of(context).textTheme.subtitle2!.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                  context: context,
                  backGroundColor: Colors.transparent,
                  titleColor: Colors.white,
                  onTap: () async {
                    UserCubit.getUserCubit(context).signOut().then(
                      (response) {
                        if (response) {
                          CashHelper.clearCashImages().then(
                            (value) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return LoginScreen();
                                  },
                                ),
                              );
                            },
                          );
                        }
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              Container(
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
                  overLayColor: Colors.grey,
                  isTitleUpperCase: false,
                  title: 'black Theme',
                  hintStyle: Theme.of(context).textTheme.subtitle2!.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                  titleColor: Colors.white,
                  context: context,
                  backGroundColor: Colors.transparent,
                  onTap: () async {
                    await CashHelper.saveDataInCash(
                      key: 'userLatestThemeMode',
                      value: true,
                    );
                    LayoutCubit.getLayoutCubit(context).switchThemeMode(
                      isDarkMode: true,
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              Container(
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
                  overLayColor: Colors.grey,
                  isTitleUpperCase: false,
                  title: 'light Theme',
                  hintStyle: Theme.of(context).textTheme.subtitle2!.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                  context: context,
                  backGroundColor: Colors.transparent,
                  titleColor: Colors.white,
                  onTap: () async {
                    await CashHelper.saveDataInCash(
                      key: 'userLatestThemeMode',
                      value: false,
                    );
                    LayoutCubit.getLayoutCubit(context).switchThemeMode(
                      isDarkMode: false,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
