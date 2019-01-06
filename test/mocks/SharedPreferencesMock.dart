class SharedPreferencesMock {
  var data = new Map<String, dynamic>();

  void setString(key, value) {
    data[key] = value;
  }

  void setStringList(key, value) {
    data[key] = value;
  }

  void setBool(key, value) {
    data[key] = value;
  }

  String getString(key) {
    return data[key];
  }

  List<String> getStringList(key) {
    return data[key];
  }

  bool getBool(key) {
    return data[key];
  }
}
