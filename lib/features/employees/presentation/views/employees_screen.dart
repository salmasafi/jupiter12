// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jupiter_academy/features/login/salary/presentation/views/employee_data.dart';
import 'package:jupiter_academy/features/login/salary/presentation/views/salary_screen.dart';
import '../../../../core/services/firebase_api.dart';
import '../../../../core/utils/styles.dart';
import '../../../../core/widgets/stars_widget.dart';
import '../../../attendance/logic/attendance_screen_builder.dart';
import '../../../profile_editing/presentation/views/profilescreen.dart';
import '../../logic/models/employee_model.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({
    super.key,
    required this.employees,
  });

  final List<Employee> employees;

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  Future<Map<String, dynamic>> _fetchRating(String id) async {
    try {
      DocumentSnapshot userDoc = await FirebaseApi.getEmployeeDoc(id: id).get();

      if (userDoc.exists && userDoc.data() != null) {
        var data = userDoc.data() as Map<String, dynamic>;
        int rating = data['rate']['totalRate'];
        int daysRating = data['rate']['daysRating'];

        double totalRating = daysRating != 0 ? (rating / daysRating) / 2 : 0.0;

        return {
          'totalRating': totalRating,
          'rating': rating,
          'daysRating': daysRating,
        };
      } else {
        print('error while fetching data');
        return {
          'totalRating': 0.0,
          'rating': 0,
          'daysRating': 0,
        };
      }
    } catch (e) {
      print('Error fetching rating: $e');
      return {
        'totalRating': 0.0,
        'rating': 0,
        'daysRating': 0,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: widget.employees.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Card(
              child: SizedBox(
                height: 150,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 2,
                      child: SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: widget.employees[index].profileImagePath != ''
                            ? Image.network(
                                widget.employees[index].profileImagePath,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/images/logo.jpg',
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.employees[index].name,
                            style: Styles.style16Bold,
                          ),
                          Text(
                            widget.employees[index].role,
                            style: Styles.style16Bold,
                          ),
                          FutureBuilder<Map<String, dynamic>>(
                            future: _fetchRating(widget.employees[index].id),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  !snapshot.hasData) {
                                return const StarsWidget(
                                  initialRating: 0,
                                );
                              }
                              double totalRating =
                                  snapshot.data!['totalRating'];
                              return StarsWidget(
                                initialRating: totalRating,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.person),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfileScreen(
                                    userModel: widget.employees[index],
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.assignment),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AttendanceScreenBuilder(
                                    id: widget.employees[index].id,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.attach_money),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SalaryScreen(
                                    userModel: widget.employees[index],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
