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
  // On-duty status: NOT reset on sign-out — re-fetched from Supabase on next sign-in.
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

  /// Resets temporary booking, request, and service workflow state
  /// without clearing the authenticated user profile, role, or on-duty status.
  static void resetWorkflowState() {
    _activeWorker = null;
    selectedWorker.value = null;
    currentService.value = null;
    currentBookingStatus.value = 'none';
    serviceCompleted.value = false;
    paymentMade.value = false;
    // workerOnDuty is intentionally NOT reset here — persists across sign-out/sign-in.
  }

  /// Full reset: clears temporary workflow state AND authentication state.
  /// Called on user logout or invalid session.
  /// workerOnDuty is intentionally NOT cleared — the value is re-fetched from
  /// Supabase on next sign-in and must reflect whatever was last set.
  static void reset() {
    resetWorkflowState();
    currentUserProfile.value = null;
    currentWorkerProfile.value = null;
    currentRole.value = 'customer';
  }
}
