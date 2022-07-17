import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_conditional_rendering/conditional.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:full_stack_instagram_clone/models/story_model.dart';
import 'package:full_stack_instagram_clone/state_management/user_bloc/user_cubit.dart';
import 'package:full_stack_instagram_clone/state_management/user_bloc/user_cubit_states.dart';
import 'package:image_picker/image_picker.dart';
import '../../shared/custom_page_route.dart';
import '../../shared/custom_shimmer_effect.dart';
import '../../shared/shared_functions.dart';
import '../stories_module/stories_screen.dart';

class CurrentUserStoryButton extends StatefulWidget {
  @override
  State<CurrentUserStoryButton> createState() => _CurrentUserStoryButtonState();
}

class _CurrentUserStoryButtonState extends State<CurrentUserStoryButton> {
  Uint8List? _storyUrl;
  late CountdownTimerController timeController;
  int endTime = DateTime.now().minute + 1;
  @override
  void initState() {
    super.initState();
    timeController = CountdownTimerController(
      endTime: endTime,
      onEnd: () {
        print('countdown is here ');
        _storyUrl = null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userCubit = UserCubit.getUserCubit(context);
    return BlocConsumer<UserCubit, UserStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(50),
              radius: 50,
              onTap: () async {
                if (_storyUrl != null) {
                  await Navigator.push(
                    context,
                    CustomPageRoute(
                      child: StoriesScreen(
                        userCubit.currentUser.uID!,
                      ),
                      direction: AxisDirection.right,
                    ),
                  ).then((value) {
                    UserCubit.getUserCubit(context).hidePersistentTabView();
                  });
                } else {
                  Uint8List file = await pickImage(source: ImageSource.gallery);
                  setState(() {
                    _storyUrl = file;
                  });
                  userCubit.addNewStory(
                    userID: userCubit.currentUser.uID!,
                    userName: userCubit.currentUser.userName!,
                    mediaType: MediaType.image,
                    storyUrl: _storyUrl!,
                  );
                }
              },
              child: Conditional.single(
                  context: context,
                  conditionBuilder: (context) => _storyUrl == null,
                  widgetBuilder: (context) {
                    return Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                          ),
                          child: Container(
                            margin: EdgeInsets.all(5.0),
                            width: 65,
                            height: 65,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: _storyUrl != null
                                  ? Image(
                                      image: MemoryImage(_storyUrl!),
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: userCubit
                                          .currentUser.profileImage
                                          .toString(),
                                      fit: BoxFit.cover,
                                      placeholder: (context, image) {
                                        return customCircularShimmerEffect(
                                          context: context,
                                          width: 65,
                                          height: 65,
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 50,
                          left: 50,
                          child: Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Icon(
                              Icons.add_circle,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  fallbackBuilder: (context) {
                    return Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF9B2282),
                            Color(0xFFEEA863),
                          ],
                        ),
                      ),
                      child: Container(
                        margin: EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Container(
                          margin: EdgeInsets.all(3.0),
                          width: 65,
                          height: 65,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: _storyUrl != null
                                ? Image(
                                    image: MemoryImage(_storyUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : CachedNetworkImage(
                                    imageUrl: userCubit.currentUser.profileImage
                                        .toString(),
                                    fit: BoxFit.cover,
                                    placeholder: (context, image) {
                                      return customCircularShimmerEffect(
                                        context: context,
                                        width: 65,
                                        height: 65,
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ),
                    );
                  }),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 5),
              child: Text(
                'your story',
                style: Theme.of(context).textTheme.subtitle2!.copyWith(
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }
}
