import 'package:googleapis/admin/directory_v1.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis_auth/googleapis_auth.dart';

/// Data provider for calendar resources and free busy status.
class CalendarsDataProvider {
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
}
