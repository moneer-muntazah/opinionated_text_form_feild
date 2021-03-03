import 'package:flutter/material.dart';
import 'dart:async';
import 'package:opinionated_text_from_field/opinionated_text_from_field.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Center(
            child: Form(
              key: formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 15),
                  OpinionatedTextFormField(
                    labelText: 'label text',
                    validator: (value) {
                      print(value);
                      if (value.isEmpty || value == '12345678') {
                        return 'no cannot do from validator';
                      }
                      return null;
                    },
                    maxLength: 8,
                    feedbacker: (value) async {
                      // await Future.delayed(Duration(seconds: 5));
                      // throw Exception
                      return Future.delayed(
                        Duration(seconds: 5),
                        () => const Opinion(
                            'Dont panic it is just a simultaneous validation!',
                            color: Colors.amber,
                            enforceRule: true),
                      );
                    },
                    onError: (e) {
                      print(e);
                    },
                  ),
                  const SizedBox(height: 15),
                  RaisedButton(
                      child: Text('validate'),
                      onPressed: () {
                        print('valid = ${formKey.currentState.validate()}');
                      })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
