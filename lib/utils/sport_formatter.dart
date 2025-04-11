import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'constants.dart';

class SportFormatter{

  static IconData getSportIcon(String sport) {
    final String sportLower = sport.toLowerCase();

    if (sportLower.contains('soccer') || sportLower.contains('football')) {
      return Icons.sports_soccer;
    } else if (sportLower.contains('basket')) {
      return Icons.sports_basketball;
    } else if (sportLower.contains('tennis')) {
      return Icons.sports_tennis;
    } else if (sportLower.contains('volley')) {
      return Icons.sports_volleyball;
    } else if (sportLower.contains('baseball')) {
      return Icons.sports_baseball;
    } else if (sportLower.contains('cricket')) {
      return Icons.sports_cricket;
    } else if (sportLower.contains('run') || sportLower.contains('marathon')) {
      return Icons.directions_run;
    } else if (sportLower.contains('golf')) {
      return Icons.sports_golf;
    } else if (sportLower.contains('swim')) {
      return Icons.pool;
    } else if (sportLower.contains('cycle') || sportLower.contains('bike')) {
      return Icons.directions_bike;
    } else if (sportLower.contains('ping pong') || sportLower.contains('table tennis')) {
      return Icons.sports_tennis;
    } else if (sportLower.contains('rock') && sportLower.contains('climb')) {
      return Icons.terrain;
    } else if (sportLower.contains('yoga')) {
      return Icons.self_improvement;
    } else if (sportLower.contains('box') || sportLower.contains('boxing')) {
      return Icons.sports_mma;
    } else {
      return Icons.sports;
    }
  }

  static Color getSportColor(String sport) {
    final String sportLower = sport.toLowerCase();

    if (sportLower.contains('soccer') || sportLower.contains('football')) {
      return AppColors.sportGreen;
    } else if (sportLower.contains('basket')) {
      return AppColors.sportOrange;
    } else if (sportLower.contains('tennis')) {
      return AppColors.accent;
    } else if (sportLower.contains('volley')) {
      return AppColors.sportPink;
    } else if (sportLower.contains('baseball')) {
      return AppColors.sportPurple;
    } else if (sportLower.contains('cricket')) {
      return AppColors.sportCyan;
    } else if (sportLower.contains('run') || sportLower.contains('marathon')) {
      return AppColors.textSecondary;
    } else if (sportLower.contains('golf')) {
      return Colors.brown;
    } else if (sportLower.contains('swim')) {
      return AppColors.primary;
    } else if (sportLower.contains('cycle') || sportLower.contains('bike')) {
      return AppColors.sportRed;
    } else if (sportLower.contains('ping pong') || sportLower.contains('table tennis')) {
      return Colors.teal;
    } else if (sportLower.contains('rock') && sportLower.contains('climb')) {
      return Colors.brown[700] ?? Colors.brown;
    } else if (sportLower.contains('yoga')) {
      return Colors.purple[300] ?? Colors.purple;
    } else if (sportLower.contains('box') || sportLower.contains('boxing')) {
      return Colors.red[900] ?? Colors.red;
    } else {
      return AppColors.primary;
    }
  }
  static String getLevelDescription(String level) {
    final String levelLower = level.toLowerCase();

    if (levelLower.contains('5k')) {
      return 'Beginning runner comfortable with 5K distances';
    } else if (levelLower.contains('10k')) {
      return 'Intermediate runner comfortable with 10K distances';
    } else if (levelLower.contains('half marathon')) {
      return 'Advanced runner capable of completing half marathons';
    } else if (levelLower.contains('marathon') || levelLower.contains('elite')) {
      return 'Elite runner with marathon experience';
    } else if (levelLower.contains('v0') || levelLower.contains('v1') || levelLower.contains('v2')) {
      return 'Beginning climber handling V0-V2 bouldering problems';
    } else if (levelLower.contains('v3') || levelLower.contains('v4') || levelLower.contains('v5')) {
      return 'Intermediate climber handling V3-V5 bouldering problems';
    } else if (levelLower.contains('v6') || levelLower.contains('v7') || levelLower.contains('v8')) {
      return 'Advanced climber handling V6-V8 bouldering problems';
    } else if (levelLower.contains('v9')) {
      return 'Expert climber handling V9+ bouldering problems';
    }

    else if (levelLower.contains('beginner')) {
      return 'Just starting out and learning the basics';
    } else if (levelLower.contains('intermediate')) {
      return 'Competent with good understanding of the activity';
    } else if (levelLower.contains('advanced')) {
      return 'Highly skilled with extensive experience';
    } else if (levelLower.contains('professional') || levelLower.contains('pro')) {
      return 'Expert level with competitive experience';
    } else if (levelLower.contains('semi-pro')) {
      return 'Advanced player with some competitive experience';
    } else if (levelLower.contains('competition')) {
      return 'Skilled competitor participating in organized events';
    } else if (levelLower.contains('instructor')) {
      return 'Expert level with ability to teach others';
    } else {
      return '';
    }
  }
}