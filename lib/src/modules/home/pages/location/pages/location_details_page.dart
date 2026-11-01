import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/modules/home/pages/location/components/section_card_component.dart';
import 'package:iveco_find/src/modules/home/pages/location/controllers/location_details_controller.dart';
import 'package:iveco_find/src/shared/components/i_pagination.dart';
import 'package:iveco_find/src/shared/components/i_tag.dart';
import 'package:iveco_find/src/shared/models/location_model.dart';
import 'package:iveco_find/src/shared/models/section_model.dart';
import 'package:iveco_find/src/shared/pages/error_page.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';

class LocationDetailsPage extends StatefulWidget {
  final LocationModel location;
  const LocationDetailsPage({super.key, required this.location});

  @override
  State<LocationDetailsPage> createState() => _LocationDetailsPageState();
}

class _LocationDetailsPageState extends State<LocationDetailsPage> {
  final controller = GetIt.instance.get<LocationDetailsController>();

  @override
  void initState() {
    controller.init(widget.location);
    super.initState();
  }

  Future<void> _openSection({SectionModel? section}) async {
    final result = await context.pushNamed(
      'add-or-edit-section',
      extra: {'locationId': controller.location.id, 'section': section},
    );
    if (result == true) {
      controller.loadSections();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, value) {
        return Scaffold(
          appBar: AppBar(title: Text('Detalhes da Localidade')),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openSection(),
            child: Icon(Icons.add),
          ),
          bottomNavigationBar: controller.pagination != null
              ? IPagination(
                  currentPage: controller.currentPage,
                  totalPage: controller.pagination!.calculateTotalPages,
                  onTapPage: controller.setCurrentPage,
                )
              : SizedBox.shrink(),
          body: Padding(
            padding: EdgeInsets.all(md),
            child: Column(
              spacing: md,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: ITheme.colors.branco,
                  child: Padding(
                    padding: EdgeInsets.all(md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: ITheme.colors.primary
                                  .withOpacity(0.2),
                              child: Icon(Icons.location_on),
                            ),
                            SizedBox(width: md),
                            Text(
                              controller.location.nome,
                              style: ITheme.styles.bodyBold(),
                            ),
                          ],
                        ),
                        ITag(isActive: controller.location.ativo),
                      ],
                    ),
                  ),
                ),
                Text('Setores', style: ITheme.styles.bodyBold()),
                Expanded(
                  child: switch (controller.behaviourPage) {
                    Behaviour.loading => Center(
                      child: CircularProgressIndicator(),
                    ),
                    Behaviour.error => ErrorPage(
                      onRetry: () => controller.loadSections(),
                    ),
                    Behaviour.success =>
                      controller.sections.isEmpty
                          ? Center(child: Text('Nenhum setor cadastrado.'))
                          : ListView.builder(
                              itemCount: controller.sections.length,
                              itemBuilder: (context, index) {
                                final item = controller.sections[index];
                                return SectionCardComponent(
                                  item: item,
                                  onTap: () => _openSection(section: item),
                                );
                              },
                            ),
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
