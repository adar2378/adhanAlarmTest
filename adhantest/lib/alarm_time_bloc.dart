import 'package:adhantest/alarm_management_model.dart';
import 'package:rxdart/rxdart.dart';

class AlarmManagementBloc {
  final _inputSubject = BehaviorSubject<AlarmManagementModel>();

  Observable<AlarmManagementModel> get outputter => _inputSubject.stream;
  Sink<AlarmManagementModel> get inputter => _inputSubject.sink;

  void dispose() {
    _inputSubject.close();
  }
}

enum AlarmEvent { SET, CANCEL }



AlarmManagementBloc alarmManagementBloc = AlarmManagementBloc();