import 'package:flutter/material.dart';
import 'package:github_contributions/constants/colors.dart';
import 'package:github_contributions/widgets/space.dart';

class Input extends StatefulWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final String? hint;
  final String? prefixIcon;
  final String? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final Color? textColor;
  final bool readOnly;
  final void Function(String)? onChanged;
  const Input({
    super.key,
    this.controller,
    this.validator,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.autofillHints,
    this.textColor = Colors.white,
    this.readOnly = false,
    this.onChanged,
  });

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  bool isFocused = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isFocused
              ? Theme.of(context).colorScheme.primary
              : ConstantColors.textColor,
        ),
        boxShadow: [
          if (isFocused)
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(.5),
              blurRadius: 0,
              offset: const Offset(0, 0),
              spreadRadius: 3,
            ),
        ],
      ),
      child: Focus(
        onFocusChange: (value) => setState(() => isFocused = value),
        child: TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          autofillHints: widget.autofillHints,
          readOnly: widget.readOnly,
          onChanged: widget.onChanged,
          style: TextStyle(
            color: widget.textColor,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(16),
            hintText: widget.hint,
            hintStyle: const TextStyle(
              color: ConstantColors.textColor,
              fontSize: 16,
            ),
            fillColor: const Color(0xff242424),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide.none,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Space(14, isHorizontal: true),
                      Image.asset(
                        widget.prefixIcon!,
                        width: 24,
                        height: 24,
                      ),
                    ],
                  )
                : null,
            suffixIcon: widget.suffixIcon != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Space(14, isHorizontal: true),
                      Image.asset(
                        widget.suffixIcon!,
                        width: 24,
                        height: 24,
                        color: isFocused ? Colors.white : null,
                      ),
                    ],
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
