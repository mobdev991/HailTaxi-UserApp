import 'package:flutter/material.dart';
import 'package:grab_carride/Models/history.dart';

import '../../../Assistance/assistanceMethods.dart';

class HistoryItem extends StatelessWidget {
  final History history;
  HistoryItem({required this.history});

  @override
  Widget build(BuildContext context) {
    String pickup = 'NA';
    String dropoff = 'NA';
    if (history.pickUp!.length < 30) {
      pickup = history.pickUp!;
    } else {
      pickup = history.pickUp!.substring(0, 30);
    }
    if (history.dropOff!.length < 30) {
      dropoff = history.dropOff!;
    } else {
      dropoff = history.dropOff!.substring(0, 30);
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green),
          color: Colors.grey.withOpacity(0.2),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 10, left: 10, right: 10, bottom: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Trip Date/Time',
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        AssistantMethods.formatTripDate(history.createdAt!),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PickUp Location',
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        pickup,
                        style: TextStyle(fontSize: 12),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Destination Location',
                        style: TextStyle(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        dropoff,
                        style: TextStyle(fontSize: 12),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green),
                          color: Colors.green.withOpacity(0.1),
                        ),
                        child: Text(
                          'AUD ${history.fares}',
                          style: TextStyle(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green),
                          color: Colors.green.withOpacity(0.1),
                        ),
                        child: Text(
                          'Cash',
                          style: TextStyle(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green),
                          color: Colors.green.withOpacity(0.1),
                        ),
                        child: Text(
                          'Referral Code',
                          style: TextStyle(
                              color: Colors.green.shade800,
                              // rideDetails!.referral_code == 'false'
                              //     ? Colors.red.shade800
                              //     : Colors.green.shade800,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
