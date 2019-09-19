/// 0 is Fajr, 4 is Isha
// The string name was used to save data useing sharedpreferences for alarmstatus for each waqt
var listOfAlarmIds = [0, 1, 2, 3, 4];
String getAdhanName(int i) {
    switch (i) {
      case 0:
        return "Fajr";
        break;
      case 1:
        return "Dhuhr";
        break;
      case 2:
        return "Asr";
        break;
      case 3:
        return "Maghrib";
        break;
      case 4:
        return "Isha";
        break;

      default:
        return "Fajr";
    }
  }