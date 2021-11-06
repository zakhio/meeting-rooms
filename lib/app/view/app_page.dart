import 'dart:async';
import 'dart:collection';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/admin/directory_v1.dart';
import 'package:googleapis/calendar/v3.dart' hide Colors;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:meeting_rooms/l10n/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: const String.fromEnvironment('OAUTH_CLIENT_ID'),
  scopes: <String>[
    'profile',
    CalendarApi.calendarReadonlyScope,
    DirectoryApi.adminDirectoryResourceCalendarReadonlyScope
  ],
);

/// The main widget of this demo.
class AppPage extends StatefulWidget {
  /// Creates the main widget of this demo.
  const AppPage({Key? key}) : super(key: key);

  @override
  State createState() => AppPageState();
}

/// The state of the main widget.
class AppPageState extends State<AppPage> {
  GoogleSignInAccount? _currentUser;
  String _contactText = '';
  List<CalendarResource> _calendarResources = [];
  Set<String?> _categories = {};
  Set<String?> _buildingIds = {};
  Set<String?> _selectedCategories = {};
  Set<String?> _selectedBuildingIds = {};
  Set<String?> _nonBookableCalendarResource = {};

  SplayTreeMap<String, SplayTreeMap<String, List<CalendarResource>>>
      _calendarResourcesMap =
      SplayTreeMap<String, SplayTreeMap<String, List<CalendarResource>>>();
  Map<String, FreeBusyCalendar> _freeBusy = <String, FreeBusyCalendar>{};

  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
        const Duration(minutes: 1), (Timer t) => _refreshFreeBusy());
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        _handleGetCalendarResources();
      }
    });
    _googleSignIn.signInSilently();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _handleGetCalendarResources() async {
    setState(() {
      _contactText = 'Loading calendars info...';
    });

    // Retrieve an [auth.AuthClient] from the current [GoogleSignIn] instance.
    final client = await _googleSignIn.authenticatedClient();

    assert(client != null, 'Authenticated client missing!');

    final calendars = await getCalendarResources(client!);

    calendars!.sort((a, b) => a.resourceName == null
        ? 1
        : b.resourceName == null
            ? -1
            : a.resourceName!.compareTo(b.resourceName!));

    final categories = calendars.map((c) => c.resourceCategory).toSet();
    final buildingIds = calendars.map((c) => c.buildingId).toSet();

    final calendarResourcesMap =
        SplayTreeMap<String, SplayTreeMap<String, List<CalendarResource>>>();
    for (final cr in calendars) {
      final buildingId = cr.buildingId ?? '<EMPTY>';
      calendarResourcesMap.putIfAbsent(
          buildingId,
          () => SplayTreeMap<String, List<CalendarResource>>(
              (k1, k2) => k2.compareTo(k1)));
      final floorName = cr.floorName ?? '<EMPTY>';
      calendarResourcesMap[buildingId]!
          .putIfAbsent(floorName, () => List.empty(growable: true));
      calendarResourcesMap[buildingId]![floorName]!.add(cr);
    }

    setState(() {
      _calendarResourcesMap = calendarResourcesMap;
      _calendarResources = calendars;
      _categories = categories;
      _selectedCategories = categories;
      _buildingIds = buildingIds;
      _contactText = 'Total: ${_calendarResources.length}\ncalendars.';
    });

    await _refreshFreeBusy();
  }

  Future<void> _refreshFreeBusy() async {
    if (_currentUser == null) {
      return;
    }

    // Retrieve an [auth.AuthClient] from the current [GoogleSignIn] instance.
    final client = await _googleSignIn.authenticatedClient();

    assert(client != null, 'Authenticated client missing!');

    final calendarIds = _calendarResources
        .where((c) =>
            _selectedCategories.contains(c.resourceCategory) &&
            _selectedBuildingIds.contains(c.buildingId))
        .map((c) => c.resourceEmail!)
        .toList();

    if (calendarIds.isNotEmpty) {
      final freeBusy = await getFreeBusyCalendar(client!, calendarIds);
      setState(() {
        _nonBookableCalendarResource = freeBusy.entries
            .where((e) => e.value.errors != null && e.value.errors!.isNotEmpty)
            .map((e) => e.key)
            .toSet();
        _freeBusy = freeBusy;
      });
    }
  }

  Future<List<CalendarResource>?> getCalendarResources(
      AuthClient client) async {
    final result = <CalendarResource>[];
    CalendarResources resources;

    do {
      resources = await DirectoryApi(client).resources.calendars.list(
            'my_customer',
            // query: 'resourceCategory = CONFERENCE_ROOM AND buildingId = Munich'
          );
      if (resources.items != null) {
        result.addAll(resources.items!);
      }
    } while (resources.nextPageToken != null);

    return result;
  }

  Future<Map<String, FreeBusyCalendar>> getFreeBusyCalendar(
      AuthClient client, final List<String> calendarIds) async {
    final result = <String, FreeBusyCalendar>{};
    Iterable<FreeBusyRequestItem> items =
        calendarIds.map((id) => FreeBusyRequestItem(id: id)).toList();
    final min = DateTime.now().toUtc();
    final max = DateTime.now().add(const Duration(minutes: 60)).toUtc();

    const batchSize = 10;
    while (items.isNotEmpty) {
      final request = FreeBusyRequest(
          items: items.take(batchSize).toList(growable: false),
          timeMin: min,
          timeMax: max);

      final resources = await CalendarApi(client).freebusy.query(request);
      if (resources.calendars != null) {
        result.addAll(resources.calendars!);
      }
      items = items.skip(batchSize);
    }
    return result;
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.counterAppBarTitle),
        centerTitle: false,
        actions: [
          Center(
            child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: buildLoginStatus(context)),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: buildPage(context),
            ),
            // CounterText(),
          ],
        ),
      ),
    );
  }

  Widget buildPage(BuildContext context) {
    final user = _currentUser;
    if (user != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () async {
                const urlString = 'https://www.buymeacoffee.com/zakhio';
                if (await canLaunch(urlString)) {
                  await launch(urlString);
                }
              },
              icon: const Icon(Icons.coffee_outlined),
              label: Text(
                'Support me with a coffee',
                style: Theme.of(context).textTheme.bodyText2!.copyWith(
                      decoration: TextDecoration.underline,
                    ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 3,
                      runSpacing: 3,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text('Categories:'),
                        for (final String? category in _categories)
                          FilterChip(
                            label: Text(category ?? '<EMPTY>'),
                            selected: _selectedCategories.contains(category),
                            labelStyle: Theme.of(context).textTheme.bodyText2,
                            onSelected: (value) async {
                              setState(() {
                                if (_selectedCategories.contains(category)) {
                                  _selectedCategories.remove(category);
                                } else {
                                  _selectedCategories.add(category);
                                }
                              });
                              await _refreshFreeBusy();
                            },
                          )
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Wrap(
                      spacing: 3,
                      runSpacing: 3,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text('Building:'),
                        for (final String? buildingId in _buildingIds)
                          FilterChip(
                            label: Text(buildingId ?? '<EMPTY>'),
                            selected: _selectedBuildingIds.contains(buildingId),
                            onSelected: (value) async {
                              setState(() {
                                if (_selectedBuildingIds.contains(buildingId)) {
                                  _selectedBuildingIds.remove(buildingId);
                                } else {
                                  _selectedBuildingIds.add(buildingId);
                                }
                              });
                              await _refreshFreeBusy();
                            },
                          )
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    onPressed: _handleGetCalendarResources,
                    icon: const Icon(Icons.sync),
                  ),
                  Text(_contactText),
                ],
              ),
            ],
          ),
          for (final String buildingId in _calendarResourcesMap.keys)
            if (_selectedBuildingIds.contains(buildingId))
              buildBuildingWidget(buildingId, context)
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text('You are not currently signed in.'),
          ElevatedButton(
            onPressed: _handleSignIn,
            child: const Text('SIGN IN'),
          ),
        ],
      );
    }
  }

  Widget buildBuildingWidget(String buildingId, BuildContext context) {
    final floors = _calendarResourcesMap[buildingId]!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              buildingId,
              style: Theme.of(context).textTheme.headline5,
              textAlign: TextAlign.center,
            ),
          ),
          for (final String floorName in floors.keys)
            if (floors[floorName]!
                .where((e) =>
                    !_nonBookableCalendarResource.contains(e.resourceEmail))
                .isNotEmpty)
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Floor $floorName',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  Wrap(
                    children: [
                      for (final CalendarResource cr in floors[floorName]!)
                        if (!_nonBookableCalendarResource
                            .contains(cr.resourceEmail))
                          buildRoomCard(cr)
                    ],
                  )
                ],
              ),
        ],
      ),
    );
  }

  Card buildRoomCard(CalendarResource calendarResource) {
    final freeBusy = _freeBusy[calendarResource.resourceEmail];
    Widget? status;
    if (freeBusy == null) {
      status = const CircularProgressIndicator();
    } else {
      if (freeBusy.errors != null && freeBusy.errors!.isNotEmpty) {
        status = Text(
          freeBusy.errors![0].reason ?? '!',
          style: Theme.of(context)
              .textTheme
              .bodyText2!
              .copyWith(color: Colors.red),
        );
      } else {
        if (freeBusy.busy == null || freeBusy.busy!.isEmpty) {
          status =
              buildTimeComponent(context, false, const Duration(minutes: 60));
        } else {
          if (freeBusy.busy![0].start!.isAfter(DateTime.now())) {
            final diff = freeBusy.busy![0].start!.difference(DateTime.now());
            status = buildTimeComponent(context, false, diff);
          } else {
            final diff = freeBusy.busy![0].end!.difference(DateTime.now());
            status = buildTimeComponent(context, true, diff);
          }
        }
      }
    }
    final errors = freeBusy?.errors;
    String? error;
    if (errors != null && errors.isNotEmpty) {
      error = errors[0].reason;
    }

    return Card(
      child: SizedBox(
        width: 300,
        child: ListTile(
          title: Text((calendarResource.resourceName ?? '<empty>') +
              (calendarResource.capacity != null
                  ? ' (${calendarResource.capacity} ppl.)'
                  : '')),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (calendarResource.resourceCategory != null)
                Text(calendarResource.resourceCategory!)
            ],
          ),
          trailing: status,
        ),
      ),
    );
  }

  Widget buildLoginStatus(BuildContext context) {
    final style = OutlinedButton.styleFrom(
      primary: Colors.white,
      side: const BorderSide(color: Colors.white),
    );

    if (_currentUser == null) {
      return OutlinedButton(
        onPressed: _handleSignIn,
        style: style,
        child: const Text('Login'),
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_currentUser!.email),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: _handleSignOut,
            style: style,
            child: const Text('SIGN OUT'),
          ),
        ],
      );
    }
  }

  Widget buildTimeComponent(BuildContext context, bool busy, Duration diff) {
    final color = busy ? Colors.red : Colors.green;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${diff.inMinutes}m',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline6!.copyWith(color: color),
        ),
        Text(
          busy ? 'Busy' : 'Free',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.caption!.copyWith(color: color),
        ),
      ],
    );
  }
}
