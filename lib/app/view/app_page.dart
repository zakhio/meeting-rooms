import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meeting_rooms/app/cubit/account_cubit.dart';
import 'package:meeting_rooms/app/cubit/calendars_cubit.dart';
import 'package:meeting_rooms/app/repository/calendars_data_provider.dart';
import 'package:meeting_rooms/app/view/application_information.dart';
import 'package:meeting_rooms/app/view/calendars.dart';
import 'package:meeting_rooms/app/view/login.dart';
import 'package:meeting_rooms/l10n/l10n.dart';

/// Main app page with login component in the header and a page with calendars
/// or page which explains the application.
class AppPage extends StatelessWidget {
  const AppPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dataProvider = CalendarsDataProvider();
    return MultiBlocProvider(
      providers: [
        BlocProvider<AccountCubit>(
          create: (_) => AccountCubit()..signInSilently(),
        ),
        BlocProvider<CalendarsCubit>(
          create: (BuildContext context) =>
              CalendarsCubit(context.read<AccountCubit>(), dataProvider),
        ),
      ],
      child: const AppPageView(),
    );
  }
}

class AppPageView extends StatelessWidget {
  const AppPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final account = context.select((AccountCubit cubit) => cubit.state);

    return Scaffold(
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
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: account != null
                ? const Calendars()
                : const ApplicationInformation()),
      ),
    );
  }
}
