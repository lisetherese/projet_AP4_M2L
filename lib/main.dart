import 'package:flutter/material.dart';
import 'package:test_app/screens/users_screens/sign_in.dart';
import 'screens/splash.dart';
import 'screens/home.dart';
import 'screens/error.dart';
import 'screens/salles_screens/create.dart';
import 'screens/salles_screens/details.dart';
import 'screens/salles_screens/edit.dart';
import 'screens/salles_screens/list.dart';
import 'screens/tarifs_screens/create.dart';
import 'screens/tarifs_screens/details.dart';
import 'screens/tarifs_screens/edit.dart';
import 'screens/tarifs_screens/list.dart';
import 'screens/domaines_screens/create.dart';
import 'screens/domaines_screens/details.dart';
import 'screens/domaines_screens/edit.dart';
import 'screens/domaines_screens/list.dart';
import 'screens/reservations_screens/create.dart';
import 'screens/reservations_screens/details.dart';
//import 'screens/reservations_screens/edit.dart';
import 'screens/reservations_screens/list.dart';
import 'screens/users_screens/sign_in.dart';
import 'screens/users_screens/sign_up.dart';
import 'screens/users_screens/authentification.dart';

// Déclaration de variables de couleurs
const bleu = Color(0xFF2b4c88);
const rouge = Color(0xFFe02131);
const jaune = Color(0xFFfec816);
const bgColor = Color(0xFFFFF3D1);
const grey = Color.fromARGB(255, 109, 109, 109);
const searchColor = Color.fromARGB(255, 238, 237, 237);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'M2L app',
      initialRoute: '/splash',
      routes: {
        '/home': (context) => const Home(),
        '/splash': (context) => const SplashScreen(),
        '/createSalle': (context) => const CreateSalle(),
        '/detailsSalle': (context) => const DetailsSalle(),
        '/editSalle': (context) => const EditSalle(),
        '/listSalle': (context) => const ListSalle(),
        '/createTarif': (context) => const CreateTarif(),
        '/detailsTarif': (context) => const DetailsTarif(),
        '/editTarif': (context) => const EditTarif(),
        '/listTarif': (context) => const ListTarif(),
        '/createDomaine': (context) => const CreateDomaine(),
        '/detailsDomaine': (context) => const DetailsDomaine(),
        '/editDomaine': (context) => const EditDomaine(),
        '/listDomaine': (context) => const ListDomaine(),
        '/listReservation': (context) => const ListReservation(),
        '/createReservation': (context) => const CreateReservation(),
        '/detailsReservation': (context) => const DetailsReservation(),
        '/editReservation': (context) => const ListReservation(),
        '/signIn': (context) => SignIn(),
        '/signUp': (context) => SignUp(),
        '/error': (context) => Error(),
        '/auth': (context) => Auth(),
      },
      theme: ThemeData(
          primarySwatch: Colors.amber,
          iconTheme: const IconThemeData(color: jaune)),
      //home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
