import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:full_stack_instagram_clone/models/commentReply_model.dart';
import 'package:full_stack_instagram_clone/models/story_model.dart';
import 'package:full_stack_instagram_clone/models/user_comment_model.dart';
import 'package:full_stack_instagram_clone/models/user_model.dart';
import 'package:full_stack_instagram_clone/models/user_post_model.dart';
import 'package:full_stack_instagram_clone/util/global_variables.dart';
import 'package:full_stack_instagram_clone/shared/shared_functions.dart';
import 'package:uuid/uuid.dart';
import '../../cash/cash_helper.dart';
import 'user_cubit_states.dart';

class UserCubit extends Cubit<UserStates> {
  UserCubit(UserStates initialState) : super(initialState);

  static UserCubit getUserCubit(BuildContext context) {
    return BlocProvider.of<UserCubit>(context);
  }

  late UserModel currentUser = UserModel.getJson({
    'uID': GlobalV.auth.currentUser!.uid,
  });

  Future fetchCurrentUserPersonalData() async {
    emit(FetchUserDataWaitingState());
    FirebaseFirestore.instance
        .collection('users')
        .doc(GlobalV.auth.currentUser!.uid)
        .get()
        .then((documentSnapshot) {
      emit(
        FetchUserDocumentDataSuccessState(
          user: currentUser = UserModel.getJson(
            documentSnapshot.data() as Map<String, dynamic>,
          ),
        ),
      );
      currentUser = UserModel.getJson(
        documentSnapshot.data() as Map<String, dynamic>,
      );
    }).catchError((error) {
      emit(FetchUserDocumentDataErrorState());
    });
  }

  UserPostModel postModel = UserPostModel.getJson({});
  bool isWaiting = false;
  // this method is from the uuid package => its simply generates a unique ids .
  Future uploadUserPost({
    required String postDescriptionController,
    required Uint8List? uploadedFile,
    required String? uID,
    required String? userName,
    required String? profileImage,
  }) async {
    isWaiting = !isWaiting;
    emit(UploadUserPostWaitingState());
    String _postID = Uuid().v1();
    uploadImageToFireBaseStorage(
      childName: 'posts',
      file: uploadedFile,
      isPostImage: true,
    ).then((futurImageUrl) {
      emit(UploadUserPostImageState());
      postModel = UserPostModel(
        description: postDescriptionController,
        postPhotoUrl: futurImageUrl,
        profileImage: profileImage,
        uID: uID,
        userName: userName,
        likes: [],
        publishedDate: Timestamp.fromDate(DateTime.now()),
        postID: _postID,
        commentsCount: 0,
      );

      GlobalV.firestore
          .collection('userPosts')
          .doc(_postID)
          .set(
            postModel.sendJson(),
          )
          .then((value) {
        isWaiting = !isWaiting;
        emit(CreateUserPostDocSuccessState(doesUserPostUploded: true));
      }).catchError((error) {
        emit(CreateUserPostDocErrorState());
        print('error on creating user post doc is ${error.toString()}');
      });
    }).catchError((error) {
      print('upload post image error is ${error.toString()}');
    });
  }

  Future<void> likingApost({
    required String? uid,
    required String? postID,
    required List? likes,
  }) async {
    if (likes!.contains(uid)) {
      // so if the user already liked this post .
      GlobalV.firestore.collection('userPosts').doc(postID).update({
        'likes': FieldValue.arrayRemove([uid])
      }).then((value) {
        emit(UpdateDislikePostState());
      }).catchError((error) {
        print(error.toString());
      });
    } else {
      // if the user did not liked the post before  . then add to likes list the uid of the current user  .
      GlobalV.firestore.collection('userPosts').doc(postID).update({
        'likes': FieldValue.arrayUnion([uid])
      }).then((value) {
        emit(UpdatelikePostState());
      }).catchError((error) {
        print(error.toString());
      });
    }
  }

  void togglePostLikingAnimation(UserPostModel post) {
    post.isLiked = !post.isLiked;
    emit(TogglePostLikeAnimation());
  }

  Future<void> postUserComment({
    required String commentDes,
    required String postID,
    required userID,
    required String userName,
    required String? userProfileImage,
  }) async {
    final commentID = Uuid().v1();
    final UserCommentModel commentModel = UserCommentModel(
      uerName: userName,
      userProfileImage: userProfileImage,
      commentID: commentID,
      commentDes: commentDes,
      commentLikes: [],
      commentPublishedDate: Timestamp.fromDate(
        DateTime.now(),
      ),
      commentReplies: [],
      postID: postID,
      userID: userID,
    );
    GlobalV.firestore
        .collection('userPosts')
        .doc(postID)
        .collection('postComments')
        .doc(commentID)
        .set(
          commentModel.sendJson(),
        )
        .then((value) {
      // getting the post comments count from the comments collection  .
      GlobalV.firestore
          .collection('userPosts')
          .doc(postID)
          .collection('postComments')
          .get()
          .then((value) {
        emit(GettingCommentsCountState());
        GlobalV.firestore.collection('userPosts').doc(postID).update(
          {'commentsCount': value.docs.length},
        ).then((value) {
          // updating the post comments count  .
          emit(UpdatePostCommentsCountSatate());
        }).catchError((error) {
          print('updating the post comment count error is ${error.toString()}');
        });
      }).catchError((error) {
        print('getting the comment count error is ${error.toString()}');
      });
      print('creating new comment doc success ');
      emit(CreateNewUserCommentDocSuccessState());
    }).catchError((error) {
      print('creatigng new user comment doc error is ${error.toString()}');
      emit(CreateNewUserCommentDocErrorState());
    });
  }

  Future<void> postUserCommentReply({
    required String commentUserName,
    required String replyDes,
    required String commentID,
    required String uID,
    required String userName,
    required String userProfileImage,
    required String postID,
  }) async {
    try {
      final replyID = Uuid().v1();
      final reply = CommentReplyModel(
        commentID: commentID,
        likes: [],
        publishedDate: Timestamp.now(),
        replyDes: replyDes,
        replyID: replyID,
        userID: uID,
        userName: userName,
        userProfilePicture: userProfileImage,
        commentUserName: commentUserName,
        postID: postID,
      );
      await GlobalV.firestore
          .collection('userPosts')
          .doc(postID)
          .collection('postComments')
          .doc(commentID)
          .collection('replies')
          .doc(replyID)
          .set(
            reply.sendJson(),
          );
      print('new reply doc has been created');
      emit(CreateNewReplyDocSuccessState());
    } catch (error) {
      emit(CreateNewReplyDocErrorState());
      print('error is ${error.toString()}');
    }
  }

  bool isReply = false;
  void switchBetwwenReplyingAndCommenting(bool isReplying) {
    isReply = isReplying;
    emit(SwitchBetweenCommentingAndReplying());
  }

  String commentID = '';
  String commentUserName = '';

  bool like = false;
  Future<void> likingComment({
    required String? uid,
    required String? postID,
    required String? commentID,
    required List? likes,
  }) async {
    if (likes!.contains(uid)) {
      GlobalV.firestore
          .collection('userPosts')
          .doc(postID)
          .collection('postComments')
          .doc(commentID)
          .update({
        'commentLikes': FieldValue.arrayRemove([uid])
      }).then((value) {
        like = false;
        // emit(DisLikingCommentState());
      }).catchError((error) {
        print(error.toString());
      });
    } else {
      GlobalV.firestore
          .collection('userPosts')
          .doc(postID)
          .collection('postComments')
          .doc(commentID)
          .update({
        'commentLikes': FieldValue.arrayUnion([uid])
      }).then((value) {
        like = true;
        // emit(LikingCommentState());
      }).catchError((error) {
        print(error.toString());
      });
    }
  }

  void toggleCommentsView(UserCommentModel commentModel) {
    commentModel.showMoreReplies = !commentModel.showMoreReplies;
    emit(ToggleCommentsViewState());
  }

  Future<void> deleatingPost({required String postID}) async {
    GlobalV.firestore
        .collection('userPosts')
        .doc(postID)
        .delete()
        .then((value) {
      emit(DeleteingUserPostSuccessState());
    }).catchError((error) {
      emit(DeleteingUserPostErrorState());
    });
  }

  Future<void> followingUser({
    required String followingUserID,
  }) async {
    try {
      DocumentSnapshot snapShot = await GlobalV.firestore
          .collection('users')
          .doc(currentUser.uID)
          .get();
      List following = (snapShot.data()! as dynamic)['following'];

      if (following.contains(followingUserID)) {
        // unfollow state
        await GlobalV.firestore.collection('users').doc(followingUserID).update(
          {
            'followers': FieldValue.arrayRemove(
              [currentUser.uID],
            ),
          },
        );

        await GlobalV.firestore.collection('users').doc(currentUser.uID).update(
          {
            'following': FieldValue.arrayRemove(
              [followingUserID],
            ),
          },
        );
        // emit(FollowingNewUserSuccesssState());
      } else {
        // follow state
        await GlobalV.firestore.collection('users').doc(followingUserID).update(
          {
            'followers': FieldValue.arrayUnion(
              [currentUser.uID],
            ),
          },
        );

        await GlobalV.firestore.collection('users').doc(currentUser.uID).update(
          {
            'following': FieldValue.arrayUnion(
              [followingUserID],
            ),
          },
        );
        // emit(UnFollowingUserSuccesssState());
      }
    } catch (error) {
      emit(FollowUnfollowUserErrorState());
      print(error.toString());
    }
  }

  Future<bool> signOut() async {
    await CashHelper.removeCashData(key: 'currentUserID');
    bool resp = await CashHelper.removeCashData(key: 'userToken');
    emit(UserSignOutSuccessState(true));
    return resp;
  }

  var selectedIndex = 0;
  void toggleFollowersPageView(int index) {
    selectedIndex = index;
    emit(TogglePageViewState());
  }

  void markNeedToReBuild() {
    emit(MarkNeedToReBuildState());
  }

  Future<void> addNewStory({
    required String userID,
    required String userName,
    required MediaType mediaType,
    required Uint8List storyUrl,
  }) async {
    final _storyID = Uuid().v1();
    uploadImageToFireBaseStorage(
      childName: 'stories',
      file: storyUrl,
      isPostImage: true,
    ).then((futureStoryUrl) {
      emit(UploadUserStoryUrlSuccessState());
      final StoryModel _story = StoryModel(
        userID: userID,
        storyID: _storyID,
        userName: userName,
        storyPublishedDate: Timestamp.fromDate(
          DateTime.now(),
        ),
        duration: Duration(seconds: 10),
        mediaType: mediaType,
        url: futureStoryUrl,
        likes: [],
      );
      GlobalV.firestore
          .collection('users')
          .doc(currentUser.uID)
          .collection('story')
          .doc(_storyID)
          .set(
            _story.sendJson(),
          )
          .then((value) {
        emit(AddingNewUserStoryDocSuccessState());
      }).catchError((error) {
        emit(AddingNewUserStoryDocErrorState());
        print('AddingNewUserStoryDocErrorState error is $error');
      });
    }).catchError((error) {
      emit(UploadUserStoryUrlErrorState());
      print('UploadUserStoryUrlErrorState error is $error');
    });
  }

  Future<List<QueryDocumentSnapshot<Object?>>> fetchStories({
    required String userID,
  }) async {
    emit(FetchStoriesLoadingState());
    QuerySnapshot querySnapshot = await GlobalV.firestore
        .collection('users')
        .doc(userID)
        .collection('story')
        .get();
    emit(FetchUserStoriesSuccessState());
    return querySnapshot.docs;
  }

  void hidePersistentTabView() {
    emit(HidePresistenceTableViewState(true));
  }
}
