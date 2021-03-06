import 'dart:developer';

import 'package:aquatracking/errors/bad_login_error.dart';
import 'package:aquatracking/model/authentication_model.dart';
import 'package:aquatracking/screen/home_screen.dart';
import 'package:aquatracking/screen/register_screen.dart';
import 'package:aquatracking/service/authentication_service.dart';
import 'package:aquatracking/utils/popup_utils.dart';
import 'package:flutter/material.dart';

AuthenticationModel authModel = AuthenticationModel();

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    AuthenticationService authenticationService = AuthenticationService();
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Text('Connexion',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  )),
              const Padding(padding: EdgeInsets.only(top: 50)),
              TextFormField(
                textInputAction: TextInputAction.next,
                onChanged: (value) {
                  authModel.email = value;
                },
                cursorColor: Theme.of(context).primaryColor,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                  icon: Icon(
                    Icons.email,
                    color: Theme.of(context).primaryColor,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              TextFormField(
                onChanged: (value) {
                  authModel.password = value;
                },
                cursorColor: Theme.of(context).primaryColor,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  labelStyle: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                  icon: Icon(
                    Icons.lock,
                    color: Theme.of(context).primaryColor,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.only(top: 50)),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed)) {
                        return const Color(0xFF0781d7);
                      }
                      return Theme.of(context)
                          .highlightColor; // Use the component's default.
                    },
                  ),
                ),
                onPressed: () {
                  if(authModel.email.isEmpty) {
                    PopupUtils.showError(context, 'Email maquant', 'Veuillez saisir votre email');
                  } else if(authModel.password.isEmpty) {
                    PopupUtils.showError(context, 'Mot de passe manquant', 'Veuillez saisir votre mot de passe');
                  } else {
                    authenticationService.login(authModel.email, authModel.password).then((value) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                    }).catchError((e) {
                      if(e is BadLoginError) {
                        PopupUtils.showError(context, 'Connexion impossible', "email ou mot de passe incorrect");
                      } else {
                        PopupUtils.showError(context, 'Erreur de connexion', "Une erreur est survenue");
                      }
                    });
                  }
                },
                child: SizedBox(
                  height: 50,
                  width: 150,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Connexion',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 20,
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(left: 10)),
                      Icon(
                        Icons.arrow_forward,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Pas encore inscrit ?',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  TextButton(onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                  }, child: Text('Inscrivez-vous', style: TextStyle(color: Theme.of(context).highlightColor),)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}