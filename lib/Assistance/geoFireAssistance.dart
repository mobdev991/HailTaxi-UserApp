import '../Models/nearByAvailableDrivers.dart';

class GeoFireAssistant {
  static List<NearbyAvailableDrivers> nearByAvailableDriversList = [];

  // removing drivers that go offline
  static void remobeDriverFromList(String key) {
    int index =
        nearByAvailableDriversList.indexWhere((element) => element.key == key);
    nearByAvailableDriversList.remove(index);
  }

  // live locations for nearby drivers

  static void updateDriverNearByLocation(NearbyAvailableDrivers driver) {
    int index = nearByAvailableDriversList
        .indexWhere((element) => element.key == driver.key);

    nearByAvailableDriversList[index].latitude = driver.latitude;
    nearByAvailableDriversList[index].longitude = driver.longitude;
  }
}
