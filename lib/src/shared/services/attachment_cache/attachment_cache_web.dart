import 'attachment_cache.dart';

/// Na web o cache fica só em memória (some ao recarregar a página).
AttachmentCache createAttachmentCache() => MemoryAttachmentCache();
