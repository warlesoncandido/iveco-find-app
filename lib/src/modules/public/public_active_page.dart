import 'package:flutter/material.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/modules/home/pages/actives/components/active_status_tag.dart';
import 'package:iveco_find/src/modules/public/public_active_model.dart';
import 'package:iveco_find/src/modules/public/public_active_repository.dart';
import 'package:iveco_find/src/shared/enums/active_status.dart';

final _activePath = RegExp(r'^/a/([^/]+)/?$');

/// Id do Ativo a partir do caminho da janela (`/a/{id}`); `null` se o caminho não casar.
String? idFromPath(String path) {
  final match = _activePath.firstMatch(path);
  if (match == null) return null;
  final String id;
  try {
    id = Uri.decodeComponent(match.group(1)!).trim();
  } on ArgumentError {
    return null;
  } on FormatException {
    // Percent-encoding válido mas UTF-8 inválido (ex.: %FF).
    return null;
  }
  return id.isEmpty ? null : id;
}

enum PublicActiveState { loading, loaded, notFound, error }

class PublicActiveController extends ChangeNotifier {
  PublicActiveController({required this.id, required this.repository});

  /// `null` quando a URL não tem id: vai direto para "não encontrado".
  final String? id;
  final PublicActiveRepository repository;

  PublicActiveState state = PublicActiveState.loading;
  PublicActive? active;
  String? errorMessage;

  Future<void> load() async {
    final id = this.id;
    if (id == null) {
      state = PublicActiveState.notFound;
      notifyListeners();
      return;
    }
    state = PublicActiveState.loading;
    errorMessage = null;
    notifyListeners();

    final result = await repository.fetch(id);
    result.fold(
      (failure) {
        if (failure.code == PublicActiveRepository.notFound) {
          state = PublicActiveState.notFound;
        } else {
          state = PublicActiveState.error;
          errorMessage = failure.message;
        }
      },
      (value) {
        active = value;
        state = PublicActiveState.loaded;
      },
    );
    notifyListeners();
  }
}

class PublicActivePage extends StatefulWidget {
  const PublicActivePage({
    super.key,
    required this.id,
    required this.repository,
  });

  final String? id;
  final PublicActiveRepository repository;

  @override
  State<PublicActivePage> createState() => _PublicActivePageState();
}

class _PublicActivePageState extends State<PublicActivePage> {
  late final PublicActiveController controller = PublicActiveController(
    id: widget.id,
    repository: widget.repository,
  );

  @override
  void initState() {
    super.initState();
    controller.load();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iveco Academy - Ativo')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: ListenableBuilder(
                listenable: controller,
                builder: (context, _) => _body(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body() {
    switch (controller.state) {
      case PublicActiveState.loading:
        return const Center(child: CircularProgressIndicator());
      case PublicActiveState.notFound:
        return _Message(icon: Icons.search_off, text: 'Ativo não encontrado');
      case PublicActiveState.error:
        return _Message(
          icon: Icons.cloud_off,
          text: controller.errorMessage ?? 'Não foi possível carregar o ativo.',
          action: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: ITheme.colors.primary,
            ),
            onPressed: controller.load,
            child: const Text('Tentar novamente'),
          ),
        );
      case PublicActiveState.loaded:
        return _ActiveCard(active: controller.active!);
    }
  }
}

class _ActiveCard extends StatelessWidget {
  const _ActiveCard({required this.active});

  final PublicActive active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ITheme.colors.branco,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ITheme.colors.cinza225),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            active.nome,
            style: ITheme.styles.headerBold(color: ITheme.colors.textColor),
          ),
          const SizedBox(height: 8),
          _StatusTag(status: active.status),
          const SizedBox(height: 16),
          _Field(label: 'Código interno', value: active.codigoInterno),
          const SizedBox(height: 12),
          _Field(label: 'Localidade', value: active.localidade),
          const SizedBox(height: 12),
          _Field(label: 'Setor', value: active.setor),
          const SizedBox(height: 12),
          _Field(
            label: 'Responsável',
            value: active.responsavel ?? 'Não informado',
          ),
        ],
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final known = ActiveStatus.values.where((e) => e.value == status);
    if (known.isNotEmpty) return ActiveStatusTag(status: known.first);
    return Text(
      status,
      style: ITheme.styles.bodyTinyBold(color: ITheme.colors.cinza90),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ITheme.styles.bodyTinyRegular(color: ITheme.colors.cinza110),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: ITheme.styles.bodyRegular(color: ITheme.colors.textColor),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 48, color: ITheme.colors.cinza145),
        const SizedBox(height: 12),
        Text(
          text,
          textAlign: TextAlign.center,
          style: ITheme.styles.subTitleBold(color: ITheme.colors.cinza60),
        ),
        if (action != null) ...[const SizedBox(height: 16), action!],
      ],
    );
  }
}
