import 'package:flutter/material.dart';

ImageProvider getWebSafeImageProvider(String path) {
  // En web, XFile.path retorna un Blob URL que NetworkImage puede renderizar
  return NetworkImage(path);
}