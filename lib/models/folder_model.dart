//import 'package:flutter/material.dart';

class Folder {
  int? id;
  String name;

  Folder({
    this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}