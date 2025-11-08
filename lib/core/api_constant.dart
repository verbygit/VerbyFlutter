class ApiConstant{

  static const String baseUrl= "https://verby.net/api/";
  static const String login= "login";
  static const String employee= "employees";
  static const String createRecord= "records/store";
  static const String createMultipleRecord= "records/bulkstore";

  static  String checkPassword(String deviceID,){
    return "devices/$deviceID/passcheck";
  }
  static  String deviceInfo(String deviceID,){
    return "devices/$deviceID";
  }
  static  String records(String employeeID,){
    return "records/$employeeID/get";
  }
  static  String plan( String deviceID,){
    return "plan/$deviceID";
  }

  static  String calendar( String deviceID,){
    return "calendar/$deviceID";
  }
}