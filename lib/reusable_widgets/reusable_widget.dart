import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter

TextField reusableTextField(
  String text,
  IconData icon,
  bool isPasswordType,
  TextEditingController controller, {
  String suffixText = '',
  TextInputFormatter? inputFormatter,
}) {
  return TextField(
    controller: controller,
    obscureText: isPasswordType,
    enableSuggestions: !isPasswordType,
    autocorrect: !isPasswordType,
    cursorColor: const Color.fromARGB(255, 0, 0, 0),
    style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0).withAlpha(150)),
    inputFormatters: [
      if (inputFormatter != null) inputFormatter, // Apply the input formatter
    ],
    decoration: InputDecoration(
      prefixIcon: Icon(icon, color: const Color.fromARGB(179, 0, 0, 0)),
      labelText: text,
      labelStyle: TextStyle(
        color: const Color.fromARGB(255, 0, 0, 0).withAlpha(150),
      ),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: const Color.fromARGB(154, 213, 209, 209).withAlpha(77),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: const BorderSide(width: 0, style: BorderStyle.none),
      ),

      
      suffixText: suffixText,
      suffixStyle: TextStyle(color: const Color.fromARGB(150, 0, 0, 0)),
    ),
    keyboardType:
        isPasswordType
            ? TextInputType.visiblePassword
            : TextInputType.emailAddress,
  );
}

// historical-touch: 2025-06-04T10:15:00 by 0Jahid
