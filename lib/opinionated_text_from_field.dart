import 'dart:async';
import 'package:flutter/material.dart';

typedef _AutoFormFieldFeedbacker = FutureOr<Opinion> Function(String);
typedef _LoadingChecker = void Function(bool);
typedef _ErrorHandler = void Function(Object);

class Opinion {
  const Opinion(this.message, {this.color, this.enforce = false});

  final String message;
  final Color color;
  final bool enforce;

  @override
  String toString() => 'Opinion { message: $message, color: $color,'
      'enforce: $enforce }';
}

/// A TextFormField that can send an async request with a customized message,
/// and color, but only when the value inputted has reached its max length.
class OpinionatedTextFormField extends StatefulWidget {
  OpinionatedTextFormField(
      {Key key,
      this.initialValue,
      this.validator,
      @required this.feedbacker,
      @required this.maxLength,
      this.borderWidth = 1.0,
      this.defaultBorderColor = Colors.black12,
      InputBorder border = const OutlineInputBorder(),
      this.onSaved,
      this.labelText,
      this.contentPadding = const EdgeInsets.all(15),
      this.onError,
      this.onLoading,
      this.keyboardType})
      : assert(feedbacker != null,
            'If you do not need to use feedbacker, use TextFormField instead'),
        assert(
            maxLength != null,
            'In order for the widget to know when to call feedbacker, '
            'the expected value has to be of a set max length'),
        border = border.copyWith(
            borderSide:
                BorderSide(width: borderWidth, color: defaultBorderColor)),
        super(key: key);

  final String initialValue;
  final String labelText;
  final int maxLength;
  final double borderWidth;
  final Color defaultBorderColor;
  final FormFieldValidator<String> validator;
  final FormFieldSetter<String> onSaved;
  final _AutoFormFieldFeedbacker feedbacker;
  final InputBorder border;
  final _ErrorHandler onError;
  final TextInputType keyboardType;
  final EdgeInsets contentPadding;
  final _LoadingChecker onLoading;

  @override
  _OpinionatedTextFormFieldState createState() =>
      _OpinionatedTextFormFieldState();
}

class _OpinionatedTextFormFieldState extends State<OpinionatedTextFormField> {
  final _fieldKey = GlobalKey<FormFieldState>();
  TextStyle _errorStyle;
  InputBorder _errorBorder;
  String _changedOpinionMessage;
  Opinion _opinion;
  Opinion _enforced;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    if (widget.onLoading != null) widget.onLoading(value);
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  String _validator(String value) {
    if (_enforced != null) {
      setState(() {
        _errorStyle = TextStyle(color: _enforced.color);
        _errorBorder = widget.border.copyWith(
            borderSide:
                BorderSide(width: widget.borderWidth, color: _enforced.color));
        isLoading = false;
      });
      return _enforced.message;
    }
    if (widget.validator != null) {
      final validationMessage = widget.validator(value);
      if (validationMessage != null) {
        setState(() {
          _errorStyle = null;
          _errorBorder = null;
          isLoading = false;
        });
        return validationMessage;
      }
    }
    if (_opinion != null) {
      final _temp = _opinion;
      _opinion = null;
      setState(() {
        _errorStyle = TextStyle(color: _temp.color);
        _errorBorder = widget.border.copyWith(
            borderSide:
                BorderSide(width: widget.borderWidth, color: _temp.color));
        if (_temp.enforce == true) {
          _enforced = _temp;
        }
        isLoading = false;
      });
      return _temp.message;
    }
    setState(() {
      isLoading = false;
    });
    return null;
  }

  void _onChange(String value) async {
    _enforced = null;
    if (value != widget.initialValue &&
        value != _changedOpinionMessage &&
        value.length == widget.maxLength) {
      setState(() {
        isLoading = true;
        _changedOpinionMessage = value;
        _errorStyle = null;
        _errorBorder = null;
      });
      try {
        _opinion = await widget.feedbacker(value);
        _fieldKey.currentState.validate();
      } catch (e) {
        debugPrint(e.toString());
        setState(() {
          _changedOpinionMessage = null;
          isLoading = false;
        });
        _fieldKey.currentState.reset();
        if (widget.onError != null) widget.onError(e);
      }
    } else {
      _changedOpinionMessage = null;
    }
  }

  @override
  Widget build(BuildContext context) => TextFormField(
        key: _fieldKey,
        initialValue: widget.initialValue,
        keyboardType: widget.keyboardType,
        enabled: !isLoading,
        maxLength: widget.maxLength,
        onSaved: widget.onSaved,
        validator: _validator,
        onChanged: _onChange,
        decoration: InputDecoration(
          labelText: widget.labelText,
          errorMaxLines: 3,
          border: widget.border,
          enabledBorder: widget.border,
          counterText: '',
          errorStyle: _errorStyle,
          errorBorder: _errorBorder,
          focusedErrorBorder: _errorBorder,
          contentPadding: widget.contentPadding,
          suffixIcon: isLoading
              ? Transform(
                  transform: Matrix4.translationValues(
                      Directionality.of(context) == TextDirection.ltr
                          ? -10.0
                          : 10.0,
                      0,
                      0),
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor:
                        AlwaysStoppedAnimation(Theme.of(context).disabledColor),
                  ),
                )
              : const SizedBox(),
          suffixIconConstraints:
              const BoxConstraints(maxWidth: 20, maxHeight: 20),
        ),
      );
}
