import 'package:flutter/material.dart';

class AddressField extends StatelessWidget {
  final String? initialValue;
  final Widget? icon;
  final BorderSide? border;
  final Color? color;
  final Widget? suffix;
  final String? hint;
  final Function? onTap;
  final bool? readOnly;

  AddressField({
    this.initialValue,
    this.icon,
    this.border,
    this.color,
    this.suffix,
    this.hint,
    this.onTap,
    this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return TextFormField(
      style: TextStyle(color: theme.primaryColorDark),
      initialValue: initialValue ?? '',
      readOnly: readOnly ?? false,
      onTap: onTap as void Function()?,
      decoration: InputDecoration(
        prefixIcon: icon,
        hintText: hint ?? '',
        suffixIcon: suffix ?? SizedBox.shrink(),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(35.0),
            borderSide: border ?? BorderSide.none),
        counter: Offstage(),
        fillColor: color ?? theme.backgroundColor,
        filled: true,
      ),
    );
  }
}
