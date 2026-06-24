import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
import 'Core/injection_container.dart' as di;
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Habilitar URLs limpias (sin '#' / hash routing) para la web
  usePathUrlStrategy();
  
  await di.init(); 
  
  runApp(const MyApp());
}