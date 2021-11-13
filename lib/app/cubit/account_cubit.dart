import 'package:bloc/bloc.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/admin/directory_v1.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis_auth/googleapis_auth.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: const String.fromEnvironment('OAUTH_CLIENT_ID'),
  scopes: <String>[
    'profile',
    CalendarApi.calendarReadonlyScope,
    DirectoryApi.adminDirectoryResourceCalendarReadonlyScope
  ],
);

class AccountState {
  AccountState(this.user, this.authenticatedClient);

  GoogleSignInAccount user;
  AuthClient authenticatedClient;
}

/// Cubit responsible for current user account and client that can be used
/// to call Google APIs supports sign in and based on GoogleSignIn plugin.
class AccountCubit extends Cubit<AccountState?> {
  AccountCubit() : super(null) {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? acc) async {
      if (acc == null) {
        emit(null);
      } else {
        final client = await _googleSignIn.authenticatedClient();
        emit(AccountState(acc, client!));
      }
    });
  }

  /// Attempts to sign in a previously authenticated user without interaction.
  void signInSilently() {
    _googleSignIn.signInSilently();
  }

  /// Starts the interactive sign-in process.
  Future<void> signIn() async {
    await _googleSignIn.signIn();
  }

  /// Disconnects the current user from the app and revokes previous
  /// authentication.
  Future<void> signOut() async {
    await _googleSignIn.disconnect();
  }
}
