import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/session/mock_auth_session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MockAuthSession.restore();
  runApp(const HarvestSlotApp());
}
