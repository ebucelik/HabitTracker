class AppData {
  AppData._privateConstructor();

  static final AppData _instance = AppData._privateConstructor();

  static AppData get instance => _instance;

  bool isEntitled = false;
}
