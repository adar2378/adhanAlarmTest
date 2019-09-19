import 'package:adhantest/alarm_management_model.dart';
import 'package:adhantest/alarm_time_bloc.dart';
import 'package:adhantest/api_provider.dart';
import 'package:adhantest/resources.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdhanStatusBloc {
  final _inputSubject = BehaviorSubject<List<bool>>();
  Observable<List<bool>> get outputtr => _inputSubject.stream;
  var _anotherlist = <bool>[];
  Sink<List<bool>> get inputter => _inputSubject.sink;

  AdhanStatusBloc() {
    initialize().then((v) {
      inputter.add(v);
    });
  }

  Future<List<bool>> initialize() async {
    var list = <bool>[];
    await ApiProvider().saveTimings("Bangladesh", "Dhaka");
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    for (int i = 0; i < listOfAlarmIds.length; i++) {
      if (!sharedPreferences.containsKey(getAdhanName(i))) {
        await sharedPreferences.setBool(getAdhanName(i), false);
        list.add(false);
        _anotherlist.add(false);
      } else {
        var value = sharedPreferences.getBool(getAdhanName(i));
        list.add(value);
        _anotherlist.add(value);
      }
    }
    return list;
  }

  Future<void> updateValue(int index) async {
    print("Changing value $index");
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var newList;
    print("hereh here");
    newList = _anotherlist;
    print("here 2");
    newList[index] = !newList[index];
    print("here 3");
    if (newList[index]) {
      print("sending new value");

      alarmManagementBloc.inputter.add(AlarmManagementModel(AlarmEvent.SET, {
        "id": index,
      }));
    } else {
      print("Cancelling");
      alarmManagementBloc.inputter
          .add(AlarmManagementModel(AlarmEvent.CANCEL, {"id": index}));
    }
    await sharedPreferences.setBool(getAdhanName(index), newList[index]);
    inputter.add(newList);
  }

  void dispose() {
    _inputSubject.close();
  }
}
