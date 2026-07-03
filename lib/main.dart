import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/app.dart';
import 'core/sync/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Firebase.initializeApp();

  final box = await Hive.openBox('settings');
  final isDark = box.get('dark_mode', defaultValue: false);

  SyncService.instance.startListening();

  runApp(
    ProviderScope(
      overrides: [
        themeModeProvider.overrideWith(
          (ref) => isDark ? ThemeMode.dark : ThemeMode.light,
        ),
      ],
      child: const GraamaShaaleApp(),
    ),
  );
}