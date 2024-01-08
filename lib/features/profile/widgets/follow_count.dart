import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/theme/pallete.dart';

class FollowCount extends ConsumerWidget {
  final int count;
  final String text;

  const FollowCount({
    super.key,
    required this.count,
    required this.text,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double fontsize = 18.0;

    return Row(
      children: [
        Row(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                color: Pallete.whiteColor,
                fontSize: fontsize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              ' $text',
              style: TextStyle(
                color: Pallete.whiteColor,
                fontSize: fontsize,
              ),
            ),
          ],
        )
      ],
    );
  }
}
