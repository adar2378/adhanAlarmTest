import 'package:adhantest/time_saver.dart';
import 'package:adhantest/timing_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ApiProvider {
  final String _baseUrl = "api.aladhan.com";

  Future<void> saveTimings(String country, String city) async {
    http.Client client = http.Client();
    for (int i = 1; i < 13; i++) {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      if (!sharedPreferences.containsKey(i.toString())) {
        try {
          final response = await client.get(Uri.http(
              _baseUrl, "/v1/calendarByCity", {
            "city": city,
            "year": DateTime.now().year.toString(),
            "month": i.toString(),
            "country": country
          }));
          print(response.statusCode);
          if (response.statusCode == 200) {
            var jsoned = json.decode(response.body);
            final timing = timingFromJson(json.encode(jsoned['data']));
            // print(timing[0].timings.fajr.;

            TimeSaver timeSaver = TimeSaver();
            timeSaver.saveTiming(i, timingToJson(timing)).then((value) {
              if (value) {
                print("done saving for $i month");
              }
            });
          }
        } catch (e) {
          print(e);
        }
      }
    }
  }
}
