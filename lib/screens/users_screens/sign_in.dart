// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/screens/users_screens/sign_up.dart';
import '../error.dart';
import 'package:test_app/screens/home.dart';
import '../../widgets/auth_api.dart';
import '../../models/user.dart';
import '../../main.dart';
import 'authentification.dart';

// ignore: use_key_in_widget_constructors
class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  // ignore: unused_field
  final AuthAPI _authAPI = AuthAPI();
  final formKey = GlobalKey<FormState>();
  late String email;
  late String mdp;
  bool displayPw = true;
  var iconShow = Icons.visibility;
  var iconHide = Icons.visibility_off;
  var icon = Icons.visibility;

  void _onSeConnecter(context) async {
    final response = await _authAPI.login(email, mdp);
    if (response.statusCode == 200) {
      final item = json.decode(response.body);
      User user = User.fromJson(item);

      //set shared preferences to keep as a way of storing data on application
     await _authAPI.userSaver(user.id, user.droitReservation, user.niveauTarif,
          user.role, user.email, user.jwt);
      
      //send user to Home page 
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    } else {
      //if error from server, send user to Error page!
      Navigator.pushNamed(context, '/error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: jaune,
        title: const Text(
          "Maison des ligues",
          style: TextStyle(color: rouge),
        ),
        elevation: 16.0,
        //leading: Image.asset('assets/images/M2L net rond.png', height: 25.0),
      ),
      body: SingleChildScrollView(
        child: Container(
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
                      "Sign In",
                      style: TextStyle(
                          color: bleu,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
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
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return SignUp();
                        }));
                      },
                    ),
                    /*SizedBox(
                      width: 400,
                      child: TextButton.icon(
                        label: const Text(
                          "Se connecter !",
                          style: TextStyle(fontSize: 20.0),
                        ),
                        icon: const Icon(
                          Icons.send,
                          size: 20.0,
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            _onSeConnecter(context);
                          }
                        },
                      ),
                    ),*/
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
        ),
      ),
    );
  }
}
