import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:consumer/Locale/locales.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String? text;
  final Function? onPressed;
  final Color? borderColor;
  final Color? color;
  final TextStyle? style;
  final BorderRadius? radius;
  final double? padding;

  CustomButton({
    this.text,
    this.onPressed,
    this.borderColor,
    this.color,
    this.style,
    this.radius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return MaterialButton(
      padding: EdgeInsets.symmetric(vertical: padding ?? 12),
      onPressed: onPressed as void Function()?,
      disabledColor: theme.disabledColor,
      color: color ?? theme.buttonColor,
      shape: OutlineInputBorder(
        borderRadius: radius ?? BorderRadius.zero,
        borderSide: BorderSide(color: borderColor ?? Colors.transparent),
      ),
      child: FadedScaleAnimation(
        Text(
          text ?? AppLocalizations.of(context)!.continueText!,
          style: style ?? Theme.of(context).textTheme.button,
        ),
        durationInMilliseconds: 400,
      ),
    );
  }
}
