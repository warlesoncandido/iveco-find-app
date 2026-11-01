import 'package:flutter/material.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/shared/components/i_tag.dart';
import 'package:iveco_find/src/shared/models/location_model.dart';

class LocationCardComponent extends StatelessWidget {
  final LocationModel item;
  final Function() onTap;
  final Function() onEdit;
  const LocationCardComponent({
    super.key,
    required this.item,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ITheme.colors.branco,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: ITheme.colors.primary.withOpacity(0.2),
                    child: Icon(Icons.location_on),
                  ),
                  SizedBox(width: md),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Text(
                      item.nome,
                      style: ITheme.styles.bodyBold(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onEdit,
                child: Row(
                  children: [
                    ITag(isActive: item.ativo),
                    SizedBox(width: md),
                    Icon(Icons.edit, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
