import 'dart:async';
import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:googleapis/admin/directory_v1.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:meeting_rooms/app/cubit/account_cubit.dart';
import 'package:meeting_rooms/app/repository/calendars_data_provider.dart';

class CalendarsState {
  CalendarsState({
    this.calendarResources = const [],
    this.categories = const {},
    this.buildingIds = const {},
    this.selectedCategories = const {},
    this.selectedBuildingIds = const {},
    this.nonBookableCalendarResource = const {},
    this.calendarResourcesMap =
        const <String, Map<String, List<CalendarResource>>>{},
    this.freeBusy = const <String, FreeBusyCalendar>{},
  });

  CalendarsState copyWith(
      {List<CalendarResource>? calendarResources,
      Set<String?>? categories,
      Set<String?>? buildingIds,
      Set<String?>? selectedCategories,
      Set<String?>? selectedBuildingIds,
      Set<String?>? nonBookableCalendarResource,
      Map<String, Map<String, List<CalendarResource>>>? calendarResourcesMap,
      Map<String, FreeBusyCalendar>? freeBusy}) {
    return CalendarsState(
        calendarResources: calendarResources ?? this.calendarResources,
        categories: categories ?? this.categories,
        buildingIds: buildingIds ?? this.buildingIds,
        selectedCategories: selectedCategories ?? this.selectedCategories,
        selectedBuildingIds: selectedBuildingIds ?? this.selectedBuildingIds,
        nonBookableCalendarResource:
            nonBookableCalendarResource ?? this.nonBookableCalendarResource,
        calendarResourcesMap: calendarResourcesMap ?? this.calendarResourcesMap,
        freeBusy: freeBusy ?? this.freeBusy);
  }

  List<CalendarResource> calendarResources;

  Set<String?> categories;
  Set<String?> buildingIds;
  Set<String?> selectedCategories;
  Set<String?> selectedBuildingIds;
  Set<String?> nonBookableCalendarResource;
  Map<String, Map<String, List<CalendarResource>>> calendarResourcesMap;
  Map<String, FreeBusyCalendar> freeBusy;
}

/// Cubit responsible for current user account and client that can be used
/// to call Google APIs supports sign in and based on GoogleSignIn plugin.
class CalendarsCubit extends Cubit<CalendarsState> {
  CalendarsCubit(AccountCubit account, this.dataProvider)
      : super(CalendarsState()) {
    _updateAccount(account.state);
    account.stream.listen(_updateAccount);
  }

  Future<void> _updateAccount(AccountState? acc) async {
    timer?.cancel();
    if (acc == null) {
      authenticatedClient = null;
      emit(CalendarsState());
    } else {
      authenticatedClient = acc.authenticatedClient;
      emit(await _refreshCalendarResources(acc.authenticatedClient));
      await refreshFreeBusy(acc.authenticatedClient);
      timer = Timer.periodic(
          const Duration(minutes: 1),
          (Timer t) async =>
              {emit(await refreshFreeBusy(acc.authenticatedClient))});
    }
  }

  Future<void> toggleSelectedCategories(String? category) async {
    if (authenticatedClient != null) {
      final selectedCategories = state.selectedCategories.toSet();
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
      emit(state.copyWith(selectedCategories: selectedCategories));
      emit(await refreshFreeBusy(authenticatedClient!));
    }
  }

  Future<void> toggleSelectedBuildingIds(String? buildingId) async {
    if (authenticatedClient != null) {
      final selectedBuildingIds = state.selectedBuildingIds.toSet();
      if (selectedBuildingIds.contains(buildingId)) {
        selectedBuildingIds.remove(buildingId);
      } else {
        selectedBuildingIds.add(buildingId);
      }
      emit(state.copyWith(selectedBuildingIds: selectedBuildingIds));
      emit(await refreshFreeBusy(authenticatedClient!));
    }
  }

  Future<void> refreshCalendarResources() async {
    if (authenticatedClient != null) {
      emit(await _refreshCalendarResources(authenticatedClient!));
    }
  }

  @override
  Future<void> close() {
    timer?.cancel();
    return super.close();
  }

  Future<CalendarsState> _refreshCalendarResources(AuthClient client) async {
    final calendars = await dataProvider.getCalendarResources(client);

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

    return CalendarsState(
      calendarResourcesMap: calendarResourcesMap,
      calendarResources: calendars,
      categories: categories,
      selectedCategories: categories,
      buildingIds: buildingIds,
    );
  }

  Future<CalendarsState> refreshFreeBusy(AuthClient client) async {
    final calendarIds = state.calendarResources
        .where((c) =>
            state.selectedCategories.contains(c.resourceCategory) &&
            state.selectedBuildingIds.contains(c.buildingId))
        .map((c) => c.resourceEmail!)
        .toList();

    var nonBookableCalendarResource = <String?>{};
    var freeBusy = <String, FreeBusyCalendar>{};
    if (calendarIds.isNotEmpty) {
      freeBusy = await dataProvider.getFreeBusyCalendar(client, calendarIds);
      nonBookableCalendarResource = freeBusy.entries
          .where((e) => e.value.errors != null && e.value.errors!.isNotEmpty)
          .map((e) => e.key)
          .toSet();
    }

    return state.copyWith(
        nonBookableCalendarResource: nonBookableCalendarResource,
        freeBusy: freeBusy);
  }

  Timer? timer;
  AuthClient? authenticatedClient;
  CalendarsDataProvider dataProvider;
}
