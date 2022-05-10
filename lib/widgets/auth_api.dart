import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../env.dart';
import 'package:http/http.dart' as http;

class AuthAPI {
  Future<http.Response> signUp(String email, String mdp, String role,
      String niveauTarif, String droit) async {
    var body = jsonEncode({
      'email': email,
      'mdp': mdp,
      'role': role,
      'niveau_tarif': niveauTarif,
      'droit_reservation': droit
    });

    http.Response response = await http
        .post(Uri.parse("${Env.URL_PREFIX}/user/create_user.php"), body: body);
    return response;
    //tu dong khi logIn API return lai het data of user
    /*
    "message" => "Connexion avec succès.",
    "jwt" => $jwt,
    "id" => $user->id,
    "email" => $user->email,
    "role" => $user->role,
    "droit_reservation" => $user->droit_reservation,
    "niveau_tarif" => $user->niveau_tarif
     */
  }

  Future<http.Response> login(String email, String mdp) async {
    var body = jsonEncode({'email': email, 'mdp': mdp});

    http.Response response = await http
        .post(Uri.parse("${Env.URL_PREFIX}/user/login.php"), body: body);
    return response;
  }

  Future<void> userSaver(int id, int droit, int tarif, String role,
      String email, String jwt) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isLoggedIn", true);
    prefs.setInt("id", id);
    prefs.setInt("droit", droit);
    prefs.setInt("tarif", tarif);
    prefs.setString('role', role);
    prefs.setString('email', email);
    prefs.setString('jwt', jwt);
  }

  /*Future<String> userRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role') ?? '';
    return role;
  }*/

  /*Future<Response> getUser() async {
    var body = jsonEncode({'email': email, 'mdp': mdp});
    // phai use methode GET vi api receive $_GET['id']
    http.Response response =
        await http.post(Uri.parse("${Env.URL_PREFIX}/user/read_one_user.php"), body: body);
    return response;
    $user_arr = array(
        "id" => $user->id,
        "email" => $user->email,
        "role" => $user->role,
        "droit_reservation" => $user->droit_reservation,
        "niveau_tarif" => $user->niveau_tarif
    );
  }*/

  /*Future<String> getText (String email, String mdp, String role,
      String niveauTarif, String droit, String text) async {
    final response =
        await _authAPI.signUp(email, mdp, role, niveauTarif, droit);
    if (response.statusCode == 200) {
      final res = await _authAPI.login(email, mdp);
      final item = json.decode(res.body);
      User user = User.fromJson(item);
      //set shared preferences to keep user logged in
      await _authAPI.userSaver(user.id, user.droitReservation, user.niveauTarif,
          user.role, user.email, user.jwt);

      return  text = "L'inscription réussie!";
      
      //send user to Home page with data of user included
    } else if (response.statusCode == 400) {
     
       return text = "L'email déjà existé!";
    
      //if email already existe!
    } else {
      
      return  text = "Une erreur survenue!";
    
      //error server
    }
  }*/

}
