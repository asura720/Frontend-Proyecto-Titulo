import 'package:flutter/material.dart';

class Medication {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final List<String> times;
  final Color containerColor;
  final Color iconColor;
  bool isTaken;
  DateTime? takenDateTime;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.times,
    required this.containerColor,
    required this.iconColor,
    this.isTaken = false,
    this.takenDateTime,
  });
}