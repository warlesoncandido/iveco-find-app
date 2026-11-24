import 'package:flutter/material.dart';
import 'package:iveco_find/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:iveco_find/src/modules/home/controllers/home_controller.dart';
import 'package:iveco_find/src/shared/enums/permission.dart';
import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/modules/home/pages/location/components/location_card_component.dart';
import 'package:iveco_find/src/modules/home/pages/location/controllers/location_controller.dart';
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
  late final searchController = TextEditingController(text: controller.query);

  /// Botões de cadastrar/editar só para quem tem `cadastros:gerir` (senão a API dá 403).
  bool get _canManage =>
      GetIt.instance.get<HomeController>().can(Permission.cadastrosGerir);

  @override
  void initState() {
    controller.loadLocations();
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, value) {
        final l = AppLocalizations.of(context)!;
        // O IView só assume a tela no erro: no loading a busca continua
        // montada (não perde texto/foco a cada recarga).
        return IView(
          behaviourPage: controller.behaviourPage == Behaviour.error
              ? Behaviour.error
              : Behaviour.success,
          onRetry: () => controller.loadLocations(),
          floatingActionButton: !_canManage
              ? SizedBox.shrink()
              : FloatingActionButton(
                  onPressed: () async {
                    final result = await context.pushNamed(
                      'add-or-edit-location',
                    );
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
                ITextField(
                  label: l.locationsSearch,
                  controller: searchController,
                  suffixIcon: Icon(Icons.search),
                  maxLines: 1,
                  textInputAction: TextInputAction.search,
                  onChanged: controller.search,
                ),

                Expanded(
                  child: controller.behaviourPage == Behaviour.loading
                      ? Center(child: CircularProgressIndicator())
                      : controller.locations.isEmpty
                      ? Center(child: Text(l.locationsEmpty))
                      : ListView.builder(
                          itemCount: controller.locations.length,
                          itemBuilder: (context, index) {
                            final item = controller.locations[index];
                            return LocationCardComponent(
                              item: item,
                              onTap: () => context.pushNamed(
                                'location-details',
                                extra: item,
                              ),
                              onEdit: !_canManage
                                  ? null
                                  : () async {
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
