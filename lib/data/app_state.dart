import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../models/worker.dart';
import '../models/worker_profile.dart';

class AppState {
  static final ValueNotifier<Worker?> selectedWorker =
      ValueNotifier(null);
  static final ValueNotifier<String?> currentService =
      ValueNotifier(null);
  static final ValueNotifier<String> currentBookingStatus =
      ValueNotifier('none'); // none, active, awaiting_otp, completed, paid
  static final ValueNotifier<bool> serviceCompleted =
      ValueNotifier(false);
  static final ValueNotifier<bool> paymentMade = ValueNotifier(false);
  static final ValueNotifier<int> requestCount = ValueNotifier(0);
  static final ValueNotifier<int> notificationUnread = ValueNotifier(2);
  static final ValueNotifier<bool> workerOnDuty = ValueNotifier(false);
  static final ValueNotifier<int> workerCompletedJobs = ValueNotifier(47);
  static final ValueNotifier<int> workerEarnings = ValueNotifier(24500);
  static final ValueNotifier<double> workerRating = ValueNotifier(4.8);

  // Authenticated Supabase profile state
  static final ValueNotifier<UserProfile?> currentUserProfile =
      ValueNotifier(null);
  static final ValueNotifier<WorkerProfile?> currentWorkerProfile =
      ValueNotifier(null);
  static final ValueNotifier<String> currentRole =
      ValueNotifier('customer');

  static Worker? _activeWorker;
  static Worker? get activeWorker => _activeWorker;
  static set activeWorker(Worker? w) {
    _activeWorker = w;
    selectedWorker.value = w;
  }

  static void reset() {
    selectedWorker.value = null;
    currentService.value = null;
    currentBookingStatus.value = 'none';
    serviceCompleted.value = false;
    paymentMade.value = false;
    workerOnDuty.value = false;
    currentUserProfile.value = null;
    currentWorkerProfile.value = null;
    currentRole.value = 'customer';
  }
}
