import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opinionated_text_from_field/opinionated_text_from_field.dart';

//typedef AppCreator = MaterialApp Function(OpinionatedTextFormField);

final formKey = GlobalKey<FormState>();

MaterialApp createApp(OpinionatedTextFormField field) => MaterialApp(
      home: Scaffold(
        body: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              field,
              RaisedButton(
                onPressed: () => formKey.currentState.validate(),
              )
            ],
          ),
        ),
      ),
    );

void main() {
  setUp(() {});
  testFeedbackerAlone();
}

void testFeedbackerAlone() {
  testWidgets(
      'When max length is reached (inputted) feedbacker shows the right input, '
          'message, and color',
      (tester) async {
    const message = '200';
    const input = '12345678';
    const color = Colors.amber;
    final app = createApp(
      OpinionatedTextFormField(
          feedbacker: (value) {
            return const Opinion(message, color: color);
          },
          maxLength: 8,
          onError: (_) {}),
    );

    await tester.pumpWidget(app);

    final fieldFinder = find.byType(OpinionatedTextFormField);
    await tester.enterText(fieldFinder, input);
    await tester.pumpWidget(app);
    final inputFinder = find.text(input);
    expect(inputFinder, findsOneWidget);
    final messageFinder = find.text(message);
    expect(messageFinder, findsOneWidget);
    final material = tester.firstWidget(find.text(message)) as Text;
    expect(material.style.color, color);
  });
}
