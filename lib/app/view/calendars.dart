import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:googleapis/admin/directory_v1.dart';
import 'package:googleapis/calendar/v3.dart' hide Colors;
import 'package:meeting_rooms/app/cubit/calendars_cubit.dart';
import 'package:meeting_rooms/app/view/donate.dart';

/// The widget calendar rooms and the filters by category and buildingId,
/// the rooms are divided by floors and buildings.
class Calendars extends StatelessWidget {
  const Calendars({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final calendars = context.select((CalendarsCubit cubit) => cubit.state);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Align(
          alignment: Alignment.centerRight,
          child: Donate(),
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
                      for (final String? category in calendars.categories)
                        FilterChip(
                          label: Text(category ?? '<EMPTY>'),
                          selected:
                              calendars.selectedCategories.contains(category),
                          labelStyle: Theme.of(context).textTheme.bodyText2,
                          onSelected: (value) => context
                              .read<CalendarsCubit>()
                              .toggleSelectedCategories(category),
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
                      for (final String? buildingId in calendars.buildingIds)
                        FilterChip(
                          label: Text(buildingId ?? '<EMPTY>'),
                          selected: calendars.selectedBuildingIds
                              .contains(buildingId),
                          onSelected: (value) => context
                              .read<CalendarsCubit>()
                              .toggleSelectedBuildingIds(buildingId),
                        )
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: () =>
                      context.read<CalendarsCubit>().refreshCalendarResources(),
                  icon: const Icon(Icons.sync),
                ),
                Text('Loaded ${calendars.calendarResources.length}'),
              ],
            ),
          ],
        ),
        for (final String buildingId in calendars.calendarResourcesMap.keys)
          if (calendars.selectedBuildingIds.contains(buildingId))
            buildBuildingWidget(context, calendars, buildingId)
      ],
    );
  }

  Widget buildBuildingWidget(
      BuildContext context, CalendarsState calendars, String buildingId) {
    final floors = calendars.calendarResourcesMap[buildingId]!;

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
                .where((e) => !calendars.nonBookableCalendarResource
                    .contains(e.resourceEmail))
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
                        if (!calendars.nonBookableCalendarResource
                            .contains(cr.resourceEmail))
                          buildRoomCard(context, calendars.freeBusy, cr)
                    ],
                  )
                ],
              ),
        ],
      ),
    );
  }

  Card buildRoomCard(
      BuildContext context,
      Map<String, FreeBusyCalendar> freeBusyMap,
      CalendarResource calendarResource) {
    final freeBusy = freeBusyMap[calendarResource.resourceEmail];
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
