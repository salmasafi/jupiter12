// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/services/firebase_api.dart';
import '../presentation/views/month_screen.dart';

class MonthDetailsScreenBuilder extends StatefulWidget {
  final String id;
  final String month;
  final String name;

  const MonthDetailsScreenBuilder({
    super.key,
    required this.id,
    required this.month,
    required this.name,
  });

  @override
  _MonthDetailsScreenState createState() => _MonthDetailsScreenState();
}

class _MonthDetailsScreenState extends State<MonthDetailsScreenBuilder> {
  List<Map<String, dynamic>> checkInOuts = [];

  @override
  void initState() {
    super.initState();
    _getCheckInOuts();
  }

  _getCheckInOuts() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseApi.getCheckInOutsForThisMonthSnapshot(
        id: widget.id,
        month: widget.month,
      );

      List<Map<String, dynamic>> fetchedData = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        num totalWorkTimeAsMinutes = 0;
        //print(data);

        totalWorkTimeAsMinutes += (data['totalWorkTime']['hours'] * 60);
        totalWorkTimeAsMinutes += data['totalWorkTime']['minutes'];

        return {
          'date': doc.id,
          'checkIn': data.containsKey('checkIn') ? data['checkIn'] : '--/--',
          'checkOut': data.containsKey('checkOut') ? data['checkOut'] : '--/--',
          'checkOutDetails': data.containsKey('checkOutDetails')
              ? data['checkOutDetails']
              : '......',
          'day': data.containsKey('day')
              ? data['day']
              : '',
          'totalWorkTime': data.containsKey('totalWorkTime')
              ? data['totalWorkTime']
              : {'hours': 0, 'minutes': 0},
          'totalWorkTimeAsMinutes': totalWorkTimeAsMinutes as int,
          'rate': data.containsKey('rate') ? data['rate'] : -1,
        };
      }).toList();

      setState(() {
        checkInOuts = fetchedData.reversed.toList();
      });
    } catch (e) {
      print('Error fetching check-in/out data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MonthDetailsScreen(
        id: widget.id,
        checkInOuts: checkInOuts,
        month: widget.month,
        name: widget.name,
      ),
    );
  }
}
