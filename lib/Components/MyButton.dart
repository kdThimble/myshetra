import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;

  const MyButton({
    super.key,
    required this.onTap,
    required this.text,
  });



  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
          vertical: 10, horizontal: 20),
      child: ElevatedButton(
        onPressed: onTap,

        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
              const Color(0xFF0E3D8B)),  // Change button color
          shape:
          MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  10), // Make the button rounded
            ),
          ),
          elevation: MaterialStateProperty.resolveWith<double>(
                  (states) {
                if (states.contains(MaterialState.pressed)) {
                  return 10; // Increase elevation when pressed
                }
                return 5; // Default elevation
              }),
          padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.all(1)), // Add padding
          minimumSize: MaterialStateProperty.all<Size>(
              const Size(
                  double.infinity, 50)), // Set width to full
          // side: MaterialStateProperty.all<BorderSide>(
          //     BorderSide(color: Colors.blue)), // Add border
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: Get.width * 0.06,
            ),
          ),
        ),
      ),
    );
  }
}
