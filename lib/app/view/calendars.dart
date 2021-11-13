import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:googleapis/admin/directory_v1.dart';
import 'package:googleapis/calendar/v3.dart' hide Colors;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:meeting_rooms/app/cubit/account_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

/// The main widget of this demo.
class Calendars extends StatefulWidget {
  /// Creates the main widget of this demo.
  const Calendars({Key? key}) : super(key: key);

  @override
  State createState() => CalendarsState();
}

/// The state of the main widget.
class CalendarsState extends State<Calendars> {
  String _contactText = '';
  List<CalendarResource> _calendarResources = [];
  Set<String?> _categories = {};
  Set<String?> _buildingIds = {};
  Set<String?> _selectedCategories = {};
  final Set<String?> _selectedBuildingIds = {};
  Set<String?> _nonBookableCalendarResource = {};
  AuthClient? _authenticatedClient;

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
    assert(_authenticatedClient != null, 'Authenticated client missing!');

    final calendars = await getCalendarResources(_authenticatedClient!);

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
    if (_authenticatedClient == null) {
      return;
    }

    // Retrieve an [auth.AuthClient] from the current [GoogleSignIn] instance.
    assert(_authenticatedClient != null, 'Authenticated client missing!');

    final calendarIds = _calendarResources
        .where((c) =>
            _selectedCategories.contains(c.resourceCategory) &&
            _selectedBuildingIds.contains(c.buildingId))
        .map((c) => c.resourceEmail!)
        .toList();

    if (calendarIds.isNotEmpty) {
      final freeBusy =
          await getFreeBusyCalendar(_authenticatedClient!, calendarIds);
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
            // query: 'resourceCategory = CONFERENCE_ROOM
            // AND buildingId = Munich'
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

  @override
  Widget build(BuildContext context) {
    _authenticatedClient = context
        .select((AccountCubit cubit) => cubit.state?.authenticatedClient);
    if (_calendarResources.isEmpty && _authenticatedClient != null) {
      _handleGetCalendarResources();
    }

    // Retrieve an [auth.AuthClient] from the current [GoogleSignIn] instance.
    assert(_authenticatedClient != null, 'Authenticated client missing!');

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
