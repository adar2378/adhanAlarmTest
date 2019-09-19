import 'package:adhantest/timing_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimeSaver {
  Future<bool> saveTiming(int month, String timings) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      return await prefs.setString(month.toString(), timings);
    } catch (e) {
      print(e);
      throw (e);
    }
  }

  Future<List<Timing>> getTiming(int month) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String result = prefs.getString(month.toString());
      return timingFromJson(result);
    } catch (e) {
      print(e);
      throw (e);
    }
  }
}
