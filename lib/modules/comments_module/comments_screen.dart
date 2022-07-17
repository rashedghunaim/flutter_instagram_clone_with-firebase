import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:full_stack_instagram_clone/modules/comments_module/post_owner_des_comment.dart';
import 'package:full_stack_instagram_clone/util/global_variables.dart';
import '../../models/user_post_model.dart';
import 'CommentCardItem.dart';
import 'adding_comment_bottom_sction.dart';

class CommentsSCreen extends StatelessWidget {
  static const String routeName = './Comments_Screen';
  final UserPostModel post;
  final bool autoFocusKeyboard;
  CommentsSCreen({
    required this.autoFocusKeyboard,
    required this.post,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
      ),
      body: StreamBuilder(
        stream: GlobalV.firestore
            .collection('userPosts')
            .doc(post.postID)
            .collection('postComments')
            .orderBy(
              'commentPublishedDate',
              descending: false,
            )
            .snapshots()
            .handleError((error) {}),
        builder: (
          BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapShot,
        ) {
          if (snapShot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 0.4,
              ),
            );
          }

          return ListView(
            physics: BouncingScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0, top: 20.0),
                child: OwnerPostDescriptionComment(post: post),
              ),
              Container(
                color: Colors.grey,
                height: 0.1,
                width: double.infinity,
              ),
              ListView.separated(
                padding: EdgeInsets.only(top: 25.0),
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return CommentCardItem(
                    snapShot: snapShot.data!.docs[index].data(),
                    postID: post.postID.toString(),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(height: 10);
                },
                itemCount: snapShot.data!.docs.length,
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: AddingCommentBottomSection(
        post: post,
        autoFocusKeyboard: autoFocusKeyboard,
      ),
    );
  }
}
