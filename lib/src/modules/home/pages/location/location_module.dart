import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/modules/home/pages/location/pages/add_or_edit_location_page.dart';
import 'package:iveco_find/src/modules/home/pages/location/pages/add_or_edit_section_page.dart';
import 'package:iveco_find/src/modules/home/pages/location/pages/location_details_page.dart';
import 'package:iveco_find/src/modules/home/pages/location/pages/location_page.dart';
import 'package:iveco_find/src/shared/models/location_model.dart';
import 'package:iveco_find/src/shared/models/section_model.dart';

final locationModule = GoRoute(
  path: '/location',
  name: 'location',
  builder: (context, state) => const LocationPage(),
  routes: [
    GoRoute(
      name: 'add-or-edit-location',
      path: '/add-or-edit-location',
      builder: (context, state) =>
          AddOrEditLocationPage(location: state.extra as LocationModel?),
    ),
    GoRoute(
      name: 'location-details',
      path: '/location-details',
      builder: (context, state) =>
          LocationDetailsPage(location: state.extra as LocationModel),
    ),
    GoRoute(
      name: 'add-or-edit-section',
      path: '/add-or-edit-section',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return AddOrEditSectionPage(
          locationId: extra['locationId'] as String,
          section: extra['section'] as SectionModel?,
        );
      },
    ),
  ],
);
