import 'package:flutter/material.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';

class IPagination extends StatefulWidget {
  final int currentPage;
  final int totalPage;
  final Function(int page) onTapPage;

  const IPagination({
    super.key,
    required this.currentPage,
    required this.totalPage,
    required this.onTapPage,
  });

  @override
  State<IPagination> createState() => _IPaginationState();
}

class _IPaginationState extends State<IPagination> {
  @override
  Widget build(BuildContext context) {
    if (widget.totalPage <= 1) {
      return SizedBox.shrink();
    }
    return Container(
      height: 60,
      padding: EdgeInsets.all(md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            onTap: () {
              if (widget.currentPage > 1) {
                widget.onTapPage(widget.currentPage - 1);
              }
            },
            child: Container(
              padding: EdgeInsets.all(sm),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ITheme.colors.primary.withOpacity(0.3),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_back,
                size: 16,
                color: ITheme.colors.primary,
              ),
            ),
          ),
          SizedBox(width: sm),
          Row(
            spacing: sm,
            children: List.generate(widget.totalPage, (index) {
              final page = index + 1;
              return Text(
                page.toString(),
                style: page == widget.currentPage
                    ? ITheme.styles.bodyBold()
                    : ITheme.styles.bodyLight(),
              );
            }),
          ),
          SizedBox(width: sm),

          InkWell(
            onTap: () {
              if (widget.currentPage < widget.totalPage) {
                widget.onTapPage(widget.currentPage + 1);
              }
            },
            child: Container(
              padding: EdgeInsets.all(sm),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ITheme.colors.primary.withOpacity(0.3),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_forward,
                size: 16,
                color: ITheme.colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
