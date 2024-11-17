import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool loading;
  const RoundButton(
      {super.key,
      required this.onTap,
      required this.title,
      this.loading = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
            color: Colors.white24, borderRadius: BorderRadius.circular(10)),
        child: Center(
          child: loading
              ? const CircularProgressIndicator(
                  strokeWidth: 4.5,
                  // color: Colors.white,
                )
              : Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 17),
                ),
        ),
      ),
    );
  }
}
