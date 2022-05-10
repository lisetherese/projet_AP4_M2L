import 'package:flutter/material.dart';
//import 'sign_in.dart';
//import 'sign_up.dart';
import '../../main.dart';
import '../../widgets/auth_api.dart';
import '../../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/screens/home.dart';
import 'dart:convert';
import '../error.dart';

//container to hold both our Signup() & SignIn() widgets
// ignore: use_key_in_widget_constructors
class Auth extends StatefulWidget {
  @override
  _AuthState createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  bool showSignIn = true;

  void changeWidget() {
    showSignIn = !showSignIn;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: jaune,
          title: const Text(
            "Maison des ligues",
            style: TextStyle(color: bgColor),
          ),
          elevation: 16.0,
          leading: Image.asset('assets/images/M2L net rond.png', height: 25.0),
        ),
        body: SingleChildScrollView(child: showSignIn ? signIn() : signUp()));
  }

   final AuthAPI _authAPI = AuthAPI();
    final formKey = GlobalKey<FormState>();
    late String email;
    late String mdp;
    bool displayPw = true;
    var iconShow = Icons.visibility;
    var iconHide = Icons.visibility_off;
    var icon = Icons.visibility;
    late String mdpConfirm;

  Widget signIn() {
    // ignore: unused_field
   

    void _onSeConnecter(context) async {
      final response = await _authAPI.login(email, mdp);
      if (response.statusCode == 200) {
        final item = json.decode(response.body);
        User user = User.fromJson(item);

        //set shared preferences to keep as a way of storing data on application
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool("isLoggedIn", true);
        prefs.setInt("id", user.id);
        prefs.setInt("droit", user.droitReservation);
        prefs.setInt("tarif", user.niveauTarif);
        prefs.setString('role', user.role);
        prefs.setString('email', user.email);
        prefs.setString('jwt', user.jwt);
        //send user to Home page with data of user included
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Home()));
      } else {
        //if error from server, send user to Error page!
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Error()));
      }
    }

    void switchWidget() {
      changeWidget();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0),
      child: Column(
        children: [
          SizedBox(
              height: 120,
              child: Image.asset('assets/images/M2L net rond.png')),
          Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 40),
                const Text(
                  "Se connecter",
                  style: TextStyle(
                      color: bleu, fontSize: 25, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                SizedBox(
                    width: 400,
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ce champ doit être rempli';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(hintText: "E-mail"),
                      onChanged: (val) => setState(() => email = val),
                    )),
                const SizedBox(height: 25),
                SizedBox(
                  width: 400,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ce champ doit être rempli';
                      }
                      return null;
                    },
                    obscureText: displayPw,
                    decoration: InputDecoration(
                      hintText: "Mot de passe",
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            displayPw = !displayPw;
                            displayPw ? icon = iconShow : icon = iconHide;
                          });
                        },
                        icon: Icon(icon),
                      ),
                    ),
                    onChanged: (val) => setState(() => mdp = val),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: jaune,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.all(10)),
                  child: const Text('CONNEXION'),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      _onSeConnecter(context);
                    }
                  },
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: jaune,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.all(10)),
                    child: const Text("S'INSCRIRE"),
                    onPressed: () {
                      switchWidget();
                    }),
                const SizedBox(height: 25),
                GestureDetector(
                  child: const Text(
                    "Mot de passe oublié ?",
                    style: TextStyle(
                        fontSize: 18.0,
                        decoration: TextDecoration.underline,
                        color: rouge),
                  ),
                  onTap: () {
                    // todo
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget signUp() {
    /*final AuthAPI _authAPI = AuthAPI();
    final formKey = GlobalKey<FormState>();
    late String email;
    late String mdpConfirm;
    late String mdp;
    bool displayPw = true;
    var iconShow = Icons.visibility;
    var iconHide = Icons.visibility_off;
    var icon = Icons.visibility;*/

    void _onSignUp(context) async {
      String role = "user";
      String niveauTarif = "4";
      String droit = "0";
      final response =
          await _authAPI.signUp(email, mdp, role, niveauTarif, droit);
      if (response.statusCode == 200) {
        //final item = json.decode(response.body);
        //User user = User.fromJson(item);

        //set shared preferences to keep user logged in
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool("isLoggedIn", true);

        //send user to Home page with data of user included
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Home()));
      } else if (response.statusCode == 400) {
        //if email already existe!
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Auth()));
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Error()));
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0),
      child: Column(
        children: [
          SizedBox(
              height: 120,
              child: Image.asset('assets/images/M2L net rond.png')),
          Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 40),
                const Text(
                  "S'inscrire",
                  style: TextStyle(
                      color: bleu, fontSize: 25, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                SizedBox(
                    width: 400,
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ce champ doit être rempli';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(hintText: "E-mail"),
                      onChanged: (val) => setState(() => email = val),
                    )),
                const SizedBox(height: 25),
                SizedBox(
                  width: 400,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ce champ doit être rempli';
                      }
                      return null;
                    },
                    obscureText: displayPw,
                    decoration: InputDecoration(
                      hintText: "Mot de passe",
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            displayPw = !displayPw;
                            displayPw ? icon = iconShow : icon = iconHide;
                          });
                        },
                        icon: Icon(icon),
                      ),
                    ),
                    onChanged: (val) => setState(() => mdp = val),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: 400,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ce champ doit être rempli';
                      } else if (value != mdp) {
                        return 'Mot de passe doit être pareil';
                      }
                      return null;
                    },
                    obscureText: displayPw,
                    decoration: InputDecoration(
                      hintText: "Confirmer mot de passe",
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            displayPw = !displayPw;
                            displayPw ? icon = iconShow : icon = iconHide;
                          });
                        },
                        icon: Icon(icon),
                      ),
                    ),
                    onChanged: (val) => setState(() => mdpConfirm = val),
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: jaune,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.all(10)),
                    child: const Text("S'inscrire"),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        _onSignUp(context);
                      }
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
