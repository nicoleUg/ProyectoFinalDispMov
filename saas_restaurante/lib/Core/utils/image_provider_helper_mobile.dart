import 'dart:io';
import 'package:flutter/material.dart';

ImageProvider getWebSafeImageProvider(String path) {
  return FileImage(File(path));
}