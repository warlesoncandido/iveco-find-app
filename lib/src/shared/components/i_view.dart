import 'package:flutter/material.dart';
import 'package:iveco_find/src/shared/pages/error_page.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';

class IView extends StatefulWidget {
  final Behaviour behaviourPage;
  final Widget child, bottom, floatingActionButton;
  final VoidCallback? onRetry;
  final String? errorMessage;

  const IView({
    super.key,
    required this.behaviourPage,
    required this.child,
    this.onRetry,
    this.errorMessage,
    required this.bottom,
    required this.floatingActionButton,
  });

  @override
  State<IView> createState() => _IViewState();
}

class _IViewState extends State<IView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) => switch (widget.behaviourPage) {
          Behaviour.error => ErrorPage(onRetry: widget.onRetry),
          Behaviour.loading => Center(child: CircularProgressIndicator()),
          Behaviour.success => widget.child,
        },
      ),
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: widget.bottom,
    );
  }
}
