import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants.dart';

class SignUpScreenTopImage extends StatelessWidget {
  const SignUpScreenTopImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "ورود به اکانت".toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 30),
        ),
        const SizedBox(height: defaultPadding),
        // Row(
        //   children: [
        //     const Spacer(),
        //     Expanded(
        //       flex: 8,
        //       child: Image.asset("assets/icons/blackspeed.png"),
        //     ),
        //     const Spacer(),
        //   ],
        // ),
        const SizedBox(height: defaultPadding),
      ],
    );
  }
}
