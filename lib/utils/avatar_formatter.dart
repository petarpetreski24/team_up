import 'package:flutter/material.dart';
import 'constants.dart';

class AvatarFormatter {
  static const List<Color> avatarColors = AppColors.avatarColors;

  static String getInitials(String name) {
    if (name.isEmpty) return '';

    final nameParts = name.trim().split(' ');
    if (nameParts.length > 1) {
      return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
    } else {
      return name.substring(0, 1).toUpperCase();
    }
  }

  static Color getAvatarColor(String name) {
    if (name.isEmpty) return AppColors.primary;

    final hashCode = name.hashCode;
    final colorIndex = hashCode.abs() % avatarColors.length;
    return avatarColors[colorIndex];
  }

  static Widget createAvatarWidget(
      String name, {
        required double size,
        TextStyle? textStyle,
      }) {
    return CircleAvatar(
      backgroundColor: getAvatarColor(name),
      radius: size / 2,
      child: Text(
        getInitials(name),
        style: textStyle ?? TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}