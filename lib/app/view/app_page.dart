import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meeting_rooms/app/cubit/account_cubit.dart';
import 'package:meeting_rooms/app/view/calendars.dart';
import 'package:meeting_rooms/app/view/login.dart';
import 'package:meeting_rooms/l10n/l10n.dart';

/// Main app page with login component in the header and a page with calendars
/// or page which explains the appliation.
class AppPage extends StatelessWidget {
  const AppPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocProvider(
      create: (_) => AccountCubit()..signInSilently(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.counterAppBarTitle),
          centerTitle: false,
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(child: Login()),
            )
          ],
        ),
        body: const SingleChildScrollView(
          child: Padding(padding: EdgeInsets.all(16), child: Calendars()),
        ),
      ),
    );
  }
}
