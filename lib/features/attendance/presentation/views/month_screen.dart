import 'package:flutter/material.dart';
import '../../../../core/utils/styles.dart';
import '../../../../core/utils/variables.dart';
import '../widget/edit_checkout.dart';
import '../widget/rate_widget.dart';

class MonthDetailsScreen extends StatefulWidget {
  const MonthDetailsScreen({
    super.key,
    required this.checkInOuts,
    required this.id,
    required this.month,
    required this.name,
  });

  final List<Map<String, dynamic>> checkInOuts;
  final String id;
  final String month;
  final String name;

  @override
  State<MonthDetailsScreen> createState() => _MonthDetailsScreenState();
}

class _MonthDetailsScreenState extends State<MonthDetailsScreen> {

  Map<String, dynamic> calculateMonthWorkTime(
      final List<Map<String, dynamic>> checkInOuts) {
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

    return totalWorkTime;
  }

  int _getDaysInCurrentMonthExcludingFridays() {
  final now = DateTime.now();
  final firstDayOfNextMonth = DateTime(now.year, now.month + 1, 1);
  final lastDayOfCurrentMonth = firstDayOfNextMonth.subtract(Duration(days: 1));
  final daysInMonth = lastDayOfCurrentMonth.day;

  int fridaysCount = 0;

  for (int i = 1; i <= daysInMonth; i++) {
    final day = DateTime(now.year, now.month, i);
    if (day.weekday == DateTime.friday) {
      fridaysCount++;
    }
  }

  return daysInMonth - fridaysCount;
}


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Text(
              '${widget.name}\'s checkOuts',
              style: Styles.style18BlackBold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Text(
              'Expected hours: ${_getDaysInCurrentMonthExcludingFridays() * 6}',
              style: Styles.style18BlackBold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Text(
              'Days: ${widget.checkInOuts.length}, Hours: ${calculateMonthWorkTime(widget.checkInOuts)['hours']}, Minutes: ${calculateMonthWorkTime(widget.checkInOuts)['minutes']}',
              style: Styles.style18BlackBold,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            // ignore: prefer_const_constructors
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.checkInOuts.length,
            itemBuilder: (context, index) {
              final data = widget.checkInOuts[index];

              return Card(
                child: Row(
                  children: [
                    Flexible(
                      child: ListTile(
                        title: Text(
                          '${data['date']} - ${data['day']}',
                          style: Styles.style18,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Check-In: ',
                                  style: Styles.style16Bold,
                                ),
                                Text(
                                  '${data['checkIn']}',
                                  style: Styles.style16,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Check-Out: ',
                                  style: Styles.style16Bold,
                                ),
                                Text(
                                  '${data['checkOut']}',
                                  style: Styles.style16,
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Work Time: ',
                                  style: Styles.style16Bold,
                                ),
                                Text(
                                  '${data['totalWorkTime']['hours'] ?? 0} hours, ${data['totalWorkTime']['minutes'] ?? 0} minutes',
                                  style: Styles.style16,
                                ),
                              ],
                            ),
                            Text(
                              'Check-Out-details:',
                              style: Styles.style16Bold,
                            ),
                            Text(
                              '${data['checkOutDetails']}',
                              style: Styles.style16,
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                      ),
                    ),
                    (thisUserId == widget.id)
                        ? EditCheckOutWidget(
                            id: widget.id,
                            name: widget.name,
                            month: widget.month,
                            dayCheckOut: data,
                          ) /* ApproveWidget(
                              userModel: userModel,
                              rate: checkInOuts[index]['rate'] as int,
                              month: month,
                            ) */
                        : RateWidget(
                            id: widget.id,
                            rate: (widget.checkInOuts[index]['rate']),
                            checkInOut: data,
                            month: widget.month,
                          ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

