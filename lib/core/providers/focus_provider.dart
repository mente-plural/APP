import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/routine_task_model.dart';

enum PomodoroStatus { focus, shortBreak, longBreak }

class FocusProvider extends ChangeNotifier {
  int _focusMinutes = 25;
  int _shortBreakMinutes = 5;
  int _longBreakMinutes = 15;

  late int _remainingSeconds;
  bool _isRunning = false;
  PomodoroStatus _status = PomodoroStatus.focus;
  int _completedCycles = 0;
  Timer? _timer;
  RoutineTaskModel? _selectedTask;
  bool _shouldShowCompletionPrompt = false;

  FocusProvider() {
    _remainingSeconds = _focusMinutes * 60;
  }

  int get focusMinutes => _focusMinutes;
  int get shortBreakMinutes => _shortBreakMinutes;
  int get longBreakMinutes => _longBreakMinutes;

  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  PomodoroStatus get status => _status;
  int get completedCycles => _completedCycles;
  RoutineTaskModel? get selectedTask => _selectedTask;
  bool get shouldShowCompletionPrompt => _shouldShowCompletionPrompt;

  void setFocusMinutes(int minutes) {
    _focusMinutes = minutes;
    if (_status == PomodoroStatus.focus && !_isRunning) {
      _remainingSeconds = _focusMinutes * 60;
    }
    notifyListeners();
  }

  void setShortBreakMinutes(int minutes) {
    _shortBreakMinutes = minutes;
    if (_status == PomodoroStatus.shortBreak && !_isRunning) {
      _remainingSeconds = _shortBreakMinutes * 60;
    }
    notifyListeners();
  }

  void setLongBreakMinutes(int minutes) {
    _longBreakMinutes = minutes;
    if (_status == PomodoroStatus.longBreak && !_isRunning) {
      _remainingSeconds = _longBreakMinutes * 60;
    }
    notifyListeners();
  }

  String get timerString {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  double get progress {
    int total;
    switch (_status) {
      case PomodoroStatus.focus:
        total = _focusMinutes * 60;
        break;
      case PomodoroStatus.shortBreak:
        total = _shortBreakMinutes * 60;
        break;
      case PomodoroStatus.longBreak:
        total = _longBreakMinutes * 60;
        break;
    }
    return 1 - (_remainingSeconds / total);
  }

  void setSelectedTask(RoutineTaskModel? task) {
    _selectedTask = task;
    notifyListeners();
  }

  void toggleTimer() {
    if (_isRunning) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _handleCycleComplete();
      }
    });
    notifyListeners();
  }

  void _pauseTimer() {
    _isRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  void resetTimer() {
    _pauseTimer();
    _setInitialTime();
    notifyListeners();
  }

  void _setInitialTime() {
    switch (_status) {
      case PomodoroStatus.focus:
        _remainingSeconds = _focusMinutes * 60;
        break;
      case PomodoroStatus.shortBreak:
        _remainingSeconds = _shortBreakMinutes * 60;
        break;
      case PomodoroStatus.longBreak:
        _remainingSeconds = _longBreakMinutes * 60;
        break;
    }
  }

  void _handleCycleComplete() {
    _pauseTimer();

    HapticFeedback.heavyImpact();

    if (_status == PomodoroStatus.focus) {
      _completedCycles++;
      if (_completedCycles % 4 == 0) {
        _status = PomodoroStatus.longBreak;
      } else {
        _status = PomodoroStatus.shortBreak;
      }
      
      if (_selectedTask != null) {
        _shouldShowCompletionPrompt = true;
      }
    } else {
      _status = PomodoroStatus.focus;
    }
    _setInitialTime();
    notifyListeners();
  }

  void resetCompletionPrompt() {
    _shouldShowCompletionPrompt = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

