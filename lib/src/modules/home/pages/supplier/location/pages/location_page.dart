import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/modules/home/pages/supplier/location/components/location_card_component.dart';
import 'package:iveco_find/src/modules/home/pages/supplier/location/controllers/location_controller.dart';
import 'package:iveco_find/src/shared/components/i_pagination.dart';
import 'package:iveco_find/src/shared/components/i_text_field.dart';
import 'package:iveco_find/src/shared/components/i_view.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final controller = GetIt.instance.get<LocationController>();

  @override
  void initState() {
    controller.loadLocations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, value) {
        if (controller.behaviourPage == Behaviour.loading) {
          return Center(child: CircularProgressIndicator());
        }
        return IView(
          behaviourPage: controller.behaviourPage,
          onRetry: () => controller.loadLocations(),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final result = await context.pushNamed('add-or-edit-location');
              if (result == true) {
                controller.loadLocations();
              }
            },
            child: Icon(Icons.add),
          ),
          bottom: controller.pagination != null
              ? IPagination(
                  currentPage: controller.currentPage,
                  totalPage: controller.pagination!.calculateTotalPages,
                  onTapPage: controller.setCurrentPage,
                )
              : SizedBox.shrink(),
          child: Padding(
            padding: EdgeInsets.all(md),
            child: Column(
              spacing: md,
              children: [
                ITextField(label: 'Pesquisar localidade'),

                Expanded(
                  child: ListView.builder(
                    itemCount: controller.locations.length,
                    itemBuilder: (context, index) {
                      final item = controller.locations[index];
                      return LocationCardComponent(
                        item: item,
                        onTap: () => context.pushNamed(
                          'location-details',
                          extra: item,
                        ),
                        onEdit: () async {
                          final result = await context.pushNamed(
                            'add-or-edit-location',
                            extra: item,
                          );
                          if (result == true) {
                            controller.loadLocations();
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
