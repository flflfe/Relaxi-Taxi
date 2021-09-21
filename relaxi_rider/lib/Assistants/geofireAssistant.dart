import 'package:flutter_app/Models/nearByAvailableDrivers.dart';

class GeofireAssistant
{
  static List<NearByAvailableDrivers> nearByAvailableDriversList=[];
  static void removeDriverFromList(String key)
  {
    int index= nearByAvailableDriversList.indexWhere((element)=>element.key==key);
    nearByAvailableDriversList.removeAt(index);
  }
  static void updateDriverLocationFromList(NearByAvailableDrivers driver)
  {
    int index= nearByAvailableDriversList.indexWhere((element)=>element.key==driver.key);
    nearByAvailableDriversList[index].longitude=driver.longitude;
    nearByAvailableDriversList[index].latitude=driver.latitude;
  }

}