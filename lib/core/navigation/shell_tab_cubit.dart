import 'package:flutter_bloc/flutter_bloc.dart';

/// Holds the selected bottom-navigation tab, so any screen can switch tabs
/// (for example "View on map" on the home screen opens the Map tab).
class ShellTabCubit extends Cubit<int> {
  ShellTabCubit() : super(0);

  void select(int index) => emit(index);
  void reset() => emit(0);
}
