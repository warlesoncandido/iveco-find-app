# iveco_find

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# iveco-find-app

## Página pública do Ativo (QR Code)

`lib/main_public.dart` é um segundo ponto de entrada web, independente do app (sem router,
GetIt, storage ou login). Lê o id de `/a/{id}` na URL e chama `GET /api/v1/publico/ativos/{id}`
na mesma origem (ou em `--dart-define=PUBLIC_API_URL=...`).
`PUBLIC_API_URL` serve só para dev com `flutter run` contra uma API em outra origem: quando a
API serve o build, a CSP (`connect-src 'self'`) bloqueia qualquer outra origem.

Build (servido pela API via `PUBLIC_WEB_DIR`, assets em `/qr/`):

```sh
flutter build web -t lib/main_public.dart --base-href /qr/ --no-web-resources-cdn -o build/public_web
```
