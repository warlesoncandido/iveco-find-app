import 'package:flutter/material.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/shared/components/i_tag.dart';
import 'package:iveco_find/src/shared/enums/user_profile.dart';
import 'package:iveco_find/src/shared/models/user_model.dart';

class UserCardComponent extends StatelessWidget {
  final UserModel item;
  final Function() onTap;
  const UserCardComponent({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final perfil = UserProfile.fromValue(item.perfil)?.label ?? item.perfil;
    return Card(
      color: ITheme.colors.branco,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(md),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: ITheme.colors.primary.withValues(alpha: 0.2),
                child: Icon(Icons.person_outline),
              ),
              SizedBox(width: md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nome,
                      style: ITheme.styles.bodyBold(),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.email,
                      overflow: TextOverflow.ellipsis,
                      style: ITheme.styles.bodyLight(
                        color: ITheme.colors.cinza145,
                      ),
                    ),
                    Text(
                      perfil,
                      style: ITheme.styles.bodyLight(
                        color: ITheme.colors.cinza145,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: md),
              ITag(isActive: item.ativo),
              SizedBox(width: md),
              Icon(Icons.edit, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
