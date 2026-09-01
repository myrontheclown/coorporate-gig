import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../screens/client/client_home_shell.dart';
import '../screens/worker/worker_home_shell.dart';
import '../screens/admin/admin_home_shell.dart';

class Nav {
  static void push(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  static void pushReplacement(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  static void pop(BuildContext context, [result]) {
    Navigator.pop(context, result);
  }

  static void clearAll(BuildContext context, Widget screen) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }

  static void toClient(BuildContext context) {
    AppState.reset();
    clearAll(context, const ClientHomeShell());
  }

  static void toWorker(BuildContext context) {
    AppState.reset();
    clearAll(context, const WorkerHomeShell());
  }

  static void toAdmin(BuildContext context) {
    AppState.reset();
    clearAll(context, const AdminHomeShell());
  }
}
