import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opinionated_text_from_field/opinionated_text_from_field.dart';

const label1 = 'label';
const message1 = '500';
const input1 = '12345678';
const duration = Duration(milliseconds: 100);

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
  // testWidgets(
  //     'When an asynchronous result is awaited from the feedbacker a progress '
  //     'indicator is displayed, and onLoading is invoked with true',
  //     (tester) async {
  //   await tester.runAsync(() async {
  //     bool loading;
  //     final app = createApp(
  //       OpinionatedTextFormField(
  //           feedbacker: (value) async {
  //             return Future<Opinion>.delayed(
  //               duration,
  //               () => const Opinion(message1, color: Colors.amber),
  //             );
  //           },
  //           onLoading: (value) => loading = value,
  //           maxLength: 8),
  //     );
  //     await tester.pumpWidget(app);
  //     final fieldFinder = find.byType(OpinionatedTextFormField);
  //     await tester.enterText(fieldFinder, input1);
  //     await tester.pump();
  //     final progressIndicatorFinder = find.byType(CircularProgressIndicator);
  //     expect(progressIndicatorFinder, findsOneWidget);
  //     expect(loading, true);
  //   });
  // });

  testWidgets(
      'When max length is reached (inputted) feedbacker shows the right input, '
      'message, and color', (tester) async {
    final app = createApp(
      OpinionatedTextFormField(
          labelText: label1,
          feedbacker: (value) {
            return const Opinion(message1, color: Colors.amber);
          },
          maxLength: 8),
    );
    await tester.pumpWidget(app);
    final fieldFinder = find.byType(OpinionatedTextFormField);
    await tester.enterText(fieldFinder, input1);
    await tester.pumpAndSettle();
    final inputFinder = find.text(input1);
    expect(inputFinder, findsOneWidget);
    final messageFinder = find.text(message1);
    expect(messageFinder, findsOneWidget);
    // Testing for the right color.
    final errorTextWidget = tester.firstWidget(find.text(message1)) as Text;
    expect(errorTextWidget.style.color, Colors.amber);
    final labelTextWidget = tester.firstWidget(find.byType(DefaultTextStyle)) as DefaultTextStyle;
    expect(labelTextWidget.style.color, Colors.amber);
    // final borderWidget =
    //     tester.firstWidget(find.byType(OutlineInputBorder)) as InputBorder;
    // expect(borderWidget.borderSide.color, Colors.amber);
  });
}
