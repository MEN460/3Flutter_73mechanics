import 'package:flutter/material.dart';

class RatingBar extends StatelessWidget {
  final double rating;
  final double iconSize;
  final Color color;

  const RatingBar({
    Key? key,
    required this.rating,
    this.iconSize = 20,
    this.color = Colors.amber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor() ? Icons.star : Icons.star_border,
          size: iconSize,
          color: color,
        );
      }),
    );
  }
}
