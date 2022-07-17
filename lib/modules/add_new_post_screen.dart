import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_conditional_rendering/conditional.dart';
import 'package:full_stack_instagram_clone/state_management/user_bloc/user_cubit.dart';
import 'package:full_stack_instagram_clone/state_management/user_bloc/user_cubit_states.dart';
import 'package:full_stack_instagram_clone/shared/shared_functions.dart';
import 'package:image_picker/image_picker.dart';
import '../cash/cash_helper.dart';
import '../shared/custom_shimmer_effect.dart';
import '../shared/primary_InputField.dart';

class AddNewPostScreen extends StatefulWidget {
  @override
  _AddNewPostScreenState createState() => _AddNewPostScreenState();
}

class _AddNewPostScreenState extends State<AddNewPostScreen> {
  final _descriptionController = TextEditingController();

  Uint8List? _userUploadedFile;
  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isCurrentModeDark =
        CashHelper.getSavedCashData(key: 'userLatestThemeMode');
    return BlocConsumer<UserCubit, UserStates>(
      listener: (BuildContext context, UserStates state) {
        if (state is CreateUserPostDocSuccessState) {
          _userUploadedFile = null;
          _descriptionController.clear();
          showSnakBar(
            context: context,
            text: 'posted',
            backGroundColor: Colors.grey[400],
          );
        }
      },
      builder: (context, state) {
        final userCubit = UserCubit.getUserCubit(context);
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              'Create Post',
              style: TextStyle(
                color: isCurrentModeDark ? Colors.white : Colors.black,
              ),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () async {
                  userCubit.uploadUserPost(
                    postDescriptionController: _descriptionController.text,
                    uploadedFile: _userUploadedFile,
                    uID: userCubit.currentUser.uID,
                    userName: userCubit.currentUser.userName,
                    profileImage: userCubit.currentUser.profileImage,
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            reverse: true,
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Container(
                height: getDeviceHeight(context),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Conditional.single(
                      context: context,
                      conditionBuilder: (context) => userCubit.isWaiting,
                      widgetBuilder: (context) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: LinearProgressIndicator(
                            color: Colors.blue,
                            minHeight: 1.5,
                            backgroundColor: isCurrentModeDark
                                ? Colors.white
                                : Colors.grey[600],
                          ),
                        );
                      },
                      fallbackBuilder: (context) {
                        return SizedBox.shrink();
                      },
                    ),
                    GestureDetector(
                      onTap: () async {
                        Uint8List file =
                            await pickImage(source: ImageSource.gallery);
                        setState(() {
                          _userUploadedFile = file;
                        });
                      },
                      child: Container(
                        height: getDeviceWidth(context),
                        width: getDeviceWidth(context),
                        color: Colors.grey[300],
                        child: _userUploadedFile == null
                            ? Icon(
                                Icons.file_upload_outlined,
                                color: Colors.white70,
                                size: 150.0,
                              )
                            : Image(
                                image: MemoryImage(_userUploadedFile!),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: CachedNetworkImage(
                                  imageUrl: userCubit.currentUser.profileImage
                                      .toString(),
                                  fit: BoxFit.cover,
                                  placeholder: (context, image) {
                                    return customCircularShimmerEffect(
                                      context: context,
                                      height: 50,
                                      width: 50,
                                    );
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom,
                                ),
                                child: primaryInputField(
                                  fillColor: Colors.transparent,
                                  context: context,
                                  controller: _descriptionController,
                                  hintText: 'Write a caption',
                                  autoFocusKeyboard: false,
                                  onFieldSubmitted: (_) {
                                    if (_userUploadedFile != null &&
                                        _descriptionController
                                            .text.isNotEmpty) {
                                      userCubit.uploadUserPost(
                                        postDescriptionController:
                                            _descriptionController.text,
                                        uploadedFile: _userUploadedFile,
                                        uID: userCubit.currentUser.uID,
                                        userName:
                                            userCubit.currentUser.userName,
                                        profileImage:
                                            userCubit.currentUser.profileImage,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
