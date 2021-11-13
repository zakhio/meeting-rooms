import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:meeting_rooms/app/cubit/account_cubit.dart';

/// Login components is responsible for sign in user into Google Account and
/// based on [AccountCubit].
class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.select((AccountCubit cubit) => cubit.state?.user);

    final style = OutlinedButton.styleFrom(
      primary: Colors.white,
      side: const BorderSide(color: Colors.white),
    );

    if (user == null) {
      return OutlinedButton.icon(
        onPressed: () => context.read<AccountCubit>().signIn(),
        style: style,
        icon: const Icon(
          MdiIcons.google,
          size: 18,
        ),
        label: const Text('Sign in with Google'),
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(user.email),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () => context.read<AccountCubit>().signOut(),
            style: style,
            child: const Text('SIGN OUT'),
          ),
        ],
      );
    }
  }
}
