import 'dart:convert';

import 'package:http/http.dart' as http;

class Requests
{
  static Future<dynamic> getRequest(String url)async
  {
    var uri = Uri.parse(url);

    try {
      http.Response response = await http.get(uri);
      if (response.statusCode == 200) {
        String jSonData = response.body;
        var decodeData = jsonDecode(jSonData);
        return decodeData;
      }
      else {
        return "failed";
      }
    }
    catch(exp)
    {
      return "failed";
    }
  }
}