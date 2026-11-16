/// Rounds a student asked to be reminded about.
/// Stored as `users/{uid}/reminders/{roundId}`.
abstract class ReminderRepository {
  Stream<Set<String>> watchReminders(String uid);
  Future<void> addReminder(String uid, String roundId);
  Future<void> removeReminder(String uid, String roundId);
}
