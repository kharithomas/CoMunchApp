import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import './helper/shared_prefs.dart';
import './pages/auth/authenticate_page.dart';
import './pages/group_page.dart';
import './pages/home_page.dart';
import './services/geolocator_service.dart';
import './services/places_service.dart';
import './models/place.dart';
import './models/user.dart';
import './main_view.dart';

Future<void> main() async {
  //initialize shared preferences
  WidgetsFlutterBinding.ensureInitialized();
  await sharedPrefs.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final locatorService = GeoLocatorService();
  final placesService = PlacesService();
  var _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      if (sharedPrefs.getLoggedIn == null) sharedPrefs.saveLoggedIn = false;
      _isLoggedIn = sharedPrefs.getLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        FutureProvider(create: (context) => locatorService.getLocation()),
        ProxyProvider<Position, Future<List<Place>>>(
          update: (context, position, places) {
            return (position != null)
                ? placesService.getPlaces(position.latitude, position.longitude)
                : null;
          },
        ),
        ChangeNotifierProvider(create: (context) => User()),
      ],
      child: MaterialApp(
          title: 'CoMunch',
          debugShowCheckedModeBanner: false,
          //theme: ThemeData.light(),
          //darkTheme: ThemeData.dark(),
          home: _isLoggedIn ? MainView() : AuthenticatePage()),
    );
  }
}
