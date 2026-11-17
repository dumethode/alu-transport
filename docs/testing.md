# Testing guide

Run everything with:

```bash
flutter test
```

Run with coverage and see the result:

```bash
flutter test --coverage
# Windows: install "Coverage Gutters" in VS Code and open coverage/lcov.info
# Mac/Linux: genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html
```

## What is tested

| File | Kind | What it proves |
|---|---|---|
| `test/core/validators_test.dart` | Unit | Email, password, name rules and their polite messages |
| `test/core/formatters_test.dart` | Unit | 24/12-hour time, "4 min ago", "in 1 h 5 min" |
| `test/features/settings/settings_cubit_test.dart` | Unit | All four preferences are saved and restored after a restart |
| `test/features/auth/auth_cubit_test.dart` | Unit | Sign in, wrong password, email verification, Google, sign out |
| `test/features/auth/login_screen_test.dart` | Widget | Empty and wrong input show errors; a valid form signs in |
| `test/features/profile/user_profile_model_test.dart` | Unit | Firestore map to model and back, same field names as the ERD |
| `test/features/profile/profile_cubit_test.dart` | Unit | Setup, unapproved driver refused, name update |
| `test/features/rounds/round_eta_test.dart` | Unit | Arrival times, delay, passed stops, which round to show |
| `test/features/rounds/round_model_test.dart` | Unit | Round to Firestore map and back |
| `test/features/rounds/live_status_card_test.dart` | Widget | Live card text and the "Remind me" chip |
| `test/features/alerts/alerts_cubit_test.dart` | Unit | Loading, error message, delete, type values match the rules |
| `test/features/alerts/alert_tile_test.dart` | Widget | Alert shows stop, round, note and time |
| `test/features/map/route_geometry_test.dart` | Unit | Stop positions stay on screen; bus position per status |
| `test/features/driver/live_change_test.dart` | Unit | What each preset update and seat change does to a round |
| `test/features/driver/driver_round_cubit_test.dart` | Unit | Posting updates, failed writes, create and delete rounds |
| `test/features/driver/seats_stepper_test.dart` | Widget | Plus/minus, disabled at zero, 48dp tap size |
| `test/features/requests/student_request_cubit_test.dart` | Unit | Send, no duplicate request, cancel |

The tests use small fake repositories, so they run without Firebase or the
internet. Take a screenshot of the `flutter test` result and of the coverage
summary for the report.

## Manual checks before the demo

- Rotate the phone on every screen: nothing overflows (yellow and black stripes).
- Try a small phone (Pixel 4a, 5.8") and a large one (Pixel 7 Pro, 6.7").
- Turn on Large text in Settings and check every screen again.