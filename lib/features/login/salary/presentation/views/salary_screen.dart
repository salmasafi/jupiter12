import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jupiter_academy/core/widgets/mybutton.dart';
import 'package:jupiter_academy/features/login/salary/presentation/views/employee_data.dart';
import '../../../../../core/services/firebase_api.dart';
import '../../../../../core/utils/styles.dart';
import '../../../../../core/widgets/build_appbar_method.dart';
import '../../../logic/models/user_model.dart';

class SalaryScreen extends StatefulWidget {
  final UserModel userModel;
  const SalaryScreen({
    super.key,
    required this.userModel,
  });

  @override
  State<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> {
  int expectedHours = 0;
  void _getExpectedHours() {
    // تحويل الشهر الذي تم استخراجه إلى كائن DateTime
    DateTime selectedMonth = DateFormat('MMMM yyyy').parse(month);
    
    final firstDayOfNextMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 1);
    final lastDayOfCurrentMonth = firstDayOfNextMonth.subtract(Duration(days: 1));
    final daysInMonth = lastDayOfCurrentMonth.day;

    int fridaysCount = 0;

    for (int i = 1; i <= daysInMonth; i++) {
      final day = DateTime(selectedMonth.year, selectedMonth.month, i);
      if (day.weekday == DateTime.friday) {
        fridaysCount++;
      }
    }

    setState(() {
      expectedHours = (daysInMonth - fridaysCount) * 6;
    });
  }
  int basicSalary = 0;
  void getSalary() async {
    try {
      DocumentSnapshot employeeSnapshot =
          await FirebaseApi.getEmployeeSnapshot(id: widget.userModel.id);

      if (employeeSnapshot.exists &&
          (employeeSnapshot.data() as Map<String, dynamic>)
              .containsKey('salary')) {
        setState(() {
          basicSalary = employeeSnapshot['salary'];
        });
      }
    } catch (e) {
      print('Error retrieving salary: $e');
    }
  }

  double currentSalary = 0;
  void calculateSalary() {
    double totalWorkedTimeInHours = workedHours + (workedMinutes / 60);
    double result = hourSalary * totalWorkedTimeInHours;
    double roundedValue = (result * 100).roundToDouble() / 100;
    setState(() {
      currentSalary = roundedValue;
    });
  }

  double hourSalary = 0;
  void calculateHourSalary() {
    double result = (basicSalary / expectedHours);
    double roundedValue = (result * 1000).roundToDouble() / 1000;
    setState(() {
      hourSalary = roundedValue;
    });
  }

  String month = '';
  Future<void> _getMonth() async {
    try {
      var monthsSnapshot = await FirebaseApi.getCheckInOutForTodaySnapshot(
          id: widget.userModel.id);

      List<String> monthsList = [];

      monthsSnapshot.docs.forEach((doc) {
        monthsList.add(doc.id);
      });

      // إذا كانت القائمة فارغة، استخدم الشهر الحالي
      if (monthsList.isEmpty) {
        setState(() {
          month = DateFormat('MMMM yyyy').format(DateTime.now());
        });
      } else {
        // استخدام آخر شهر في القائمة
        setState(() {
          month = monthsList[0];
        });
      }
    } catch (e) {
      print('Error retrieving months: $e');
    }
  }
  List<Map<String, dynamic>> checkInOuts = [];
  _getCheckInOuts() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseApi.getCheckInOutsForThisMonthSnapshot(
        id: widget.userModel.id,
        month: month,
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
          'day': data.containsKey('day') ? data['day'] : '',
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

  int workedHours = 0;
  int workedMinutes = 0;
  void calculateMonthWorkTime(final List<Map<String, dynamic>> checkInOuts) {
    num totalMonthWorkTimeAsMinutes = 0;
    for (var checkInOut in checkInOuts) {
      totalMonthWorkTimeAsMinutes +=
          checkInOut['totalWorkTimeAsMinutes'] as int;
    }

    print(totalMonthWorkTimeAsMinutes);

    Map<String, dynamic> totalWorkTime = {'hours': 0, 'minutes': 0};

    while (totalMonthWorkTimeAsMinutes >= 60) {
      totalMonthWorkTimeAsMinutes -= 60;
      totalWorkTime['hours'] += 1;
    }

    totalWorkTime['minutes'] = totalMonthWorkTimeAsMinutes;

    setState(() {
      workedHours = totalWorkTime['hours'];
      workedMinutes = totalWorkTime['minutes'];
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _getMonth();
    await _getCheckInOuts();
    getSalary();
    _getExpectedHours();
    calculateMonthWorkTime(checkInOuts);
  }

  @override
  Widget build(BuildContext context) {
    calculateHourSalary();
    calculateSalary();

    return Scaffold(
      appBar: buildAppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 150,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Column(
                  children: [
                    Text(
                      '${widget.userModel.name}\'s salary for $month:',
                      style: Styles.style18BlackBold,
                    ),
                    Text(
                      '$currentSalary',
                      style: Styles.style18BlackBold,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text(
                  'Basic salary: $basicSalary',
                  style: Styles.style16Bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text(
                  'Expected hours: $expectedHours',
                  style: Styles.style16Bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text(
                  'Hour salary: $hourSalary',
                  style: Styles.style16Bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text(
                  'Worked time: $workedHours h, $workedMinutes m',
                  style: Styles.style16Bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text(
                  'Hour salary / Worked time',
                  style: Styles.style16Bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text(
                  'Current salary: $currentSalary',
                  style: Styles.style16Bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              MyButton(
                title: 'Edit employee\'s salary',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EmployeeData(
                        userModel: widget.userModel,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
