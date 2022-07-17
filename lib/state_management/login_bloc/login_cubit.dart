import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:full_stack_instagram_clone/state_management/login_bloc/login_states.dart';
import '../../util/global_variables.dart';

class LoginCubit extends Cubit<LoginStates> {
  LoginCubit(LoginStates initialState) : super(initialState);

  static LoginCubit getLoginCubit(BuildContext context) {
    return BlocProvider.of<LoginCubit>(context);
  }

  bool isPasswordShown = true;
  void togglePsswordVisibility() {
    isPasswordShown = !isPasswordShown;
    emit(TogglePasswordVisibilityLoginState());
  }

  bool isWaiting = false;
  Future<void> loginUser(
      {required String email, required String password}) async {
    isWaiting = !isWaiting;
    emit(LoginWaitingResponseState());

    GlobalV.auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((userFutureCred) {
      print('logged in user id is ${userFutureCred.user!.uid}');
      userFutureCred.user?.getIdToken().then((futureToken) {
        String? _token;
        if (futureToken.isEmpty) {
          _token = null;
          GlobalV.currenttUserToken = null;
        } else {
          _token = futureToken;
          GlobalV.currenttUserToken = futureToken;
        }

        print('login token is ${_token.toString()}');

        emit(LoginUserSuccessState(
          userToken: _token,
          currentUserID: userFutureCred.user!.uid,
        ));
        isWaiting = !isWaiting;
        print('login successed');
      }).catchError((error) {
        print('token error is ${error.toString()}');
      });
    }).catchError((error) {
      emit(LoginUserErrorState(error.toString()));
      isWaiting = !isWaiting;
      print('login error');
    });
  }
}
