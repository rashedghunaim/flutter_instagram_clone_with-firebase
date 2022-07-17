import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:full_stack_instagram_clone/models/user_model.dart';
import 'package:full_stack_instagram_clone/state_management/register_bloc/register_states.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../util/global_variables.dart';
import '../../shared/shared_functions.dart';

class RegisterCubit extends Cubit<RegisterStates> {
  RegisterCubit(RegisterStates initialState) : super(initialState);

  static RegisterCubit getRegisterCubit(BuildContext context) {
    return BlocProvider.of<RegisterCubit>(context);
  }

  bool isPasswordVisible = true;
  void togglePsswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    emit(TogglePasswordVisibiltyState());
  }

  Uint8List? selectedImage;
  void registerSelectProfileImage() {
    pickImage(source: ImageSource.gallery).then((futureImage) {
      selectedImage = futureImage;
      emit(RegisterSelectProfileImageState());
    });
  }

  String? photoUrl;
  UserModel? user;
  bool isLoading = false;
  Future registeringNewUser({
    required String userName,
    required String email,
    required String password,
    required String bio,
    required Uint8List? file,
  }) async {
    isLoading = true;
    emit(RegisterWaitingResponseState());

    GlobalV.auth
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    )
        .then((userFutureCred) {
      emit(RegisterNewUserSuccessState());
      userFutureCred.user?.getIdToken().then((futureToken) {
        String? _token;
        if (futureToken.isEmpty) {
          _token = null;
          GlobalV.currenttUserToken = null;
        } else {
          _token = futureToken;
          GlobalV.currenttUserToken = futureToken;
        }

        uploadImageToFireBaseStorage(
          childName: 'profilePics',
          file: file,
          isPostImage: false,
        ).then((futurePhotoUrl) {
          emit(RegisterUplaodProfileImageState());
          user = UserModel(
            bio: bio,
            email: email,
            profileImage: futurePhotoUrl,
            userName: userName,
            followers: [],
            following: [],
            uID: userFutureCred.user!.uid,
          );

          GlobalV.firestore
              .collection('users')
              .doc(userFutureCred.user!.uid)
              .set(user!.sendJson())
              .then((value) {
            emit(RegisterNewUserDocumentSuccessState(
              userToken: _token,
              currentUserID: userFutureCred.user!.uid,
            ));
          }).catchError((error) {
            isLoading = false;
            emit(RegisterNewUserDocumentErrorState());
          });
        });
      }).catchError((error) {
        print(
          'token error is ${error.toString()}',
        );
      });
    }).catchError((error) {
      isLoading = false;
      emit(RegisterNewUserErrorState(error.toString()));
      print('uplaoding image erros is ${error.toString()}');
    });
  }
}
