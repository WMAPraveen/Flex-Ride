import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:car_rental_app/features/vehicledetails/ratingpage.dart';
import 'package:car_rental_app/features/vehicledetails/vehicledetails.dart';
import 'package:flutter/material.dart';

class Shope extends StatefulWidget {
  final String title;
  final String location;
  final String? coverPicture;

  const Shope({
    Key? key,
    required this.title,
    required this.location,
    this.coverPicture,
  }) : super(key: key);

  @override
  State<Shope> createState() => _ShopeState();
}

