import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Models ───────────────────────────────────────────────────────────────────

class StaffTask {
  final String id;
  final String title;
  final String location;
  final bool completed;

  const StaffTask({
    required this.id,
    required this.title,
    required this.location,
    this.completed = false,
  });

  StaffTask copyWith({bool? completed}) =>
      StaffTask(id: id, title: title, location: location, completed: completed ?? this.completed);
}

class StaffHomeState {
  final String name;
  final String role;
  final String shiftTime;
  final List<StaffTask> tasks;
  final bool hasPanicSent;

  const StaffHomeState({
    required this.name,
    required this.role,
    required this.shiftTime,
    required this.tasks,
    this.hasPanicSent = false,
  });

  StaffHomeState copyWith({List<StaffTask>? tasks, bool? hasPanicSent}) =>
      StaffHomeState(
        name: name,
        role: role,
        shiftTime: shiftTime,
        tasks: tasks ?? this.tasks,
        hasPanicSent: hasPanicSent ?? this.hasPanicSent,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class StaffNotifier extends StateNotifier<StaffHomeState> {
  StaffNotifier()
      : super(const StaffHomeState(
          name: 'Sarah Chen',
          role: 'Security Chief',
          shiftTime: '08:00 – 20:00',
          tasks: [
            StaffTask(id: 't1', title: 'Patrol main lobby & entrance', location: 'Ground Floor', completed: true),
            StaffTask(id: 't2', title: 'Check fire-exit signage on Floors 1–3', location: 'Floors 1–3'),
            StaffTask(id: 't3', title: 'Kitchen fire incident walkthrough', location: 'Floor 2 · Kitchen', completed: false),
            StaffTask(id: 't4', title: 'Submit end-of-shift security log', location: 'Security Office'),
            StaffTask(id: 't5', title: 'Brief incoming shift officer', location: 'Security Office'),
          ],
        ));

  void toggleTask(String id) {
    final updated = state.tasks
        .map((t) => t.id == id ? t.copyWith(completed: !t.completed) : t)
        .toList();
    state = state.copyWith(tasks: updated);
  }

  Future<void> sendPanic() async {
    await Future.delayed(const Duration(milliseconds: 800));
    state = state.copyWith(hasPanicSent: true);
  }
}

final staffProvider =
    StateNotifierProvider<StaffNotifier, StaffHomeState>((ref) => StaffNotifier());
