import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grab_carride/screens/activity/screens/history_item.dart';
import 'package:provider/provider.dart';

import '../../providers/appData.dart';

class Activity extends StatefulWidget {
  const Activity({Key? key}) : super(key: key);

  @override
  _ActivityState createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  @override
  void initState() {
    super.initState();
  }

  bool noTrips = true;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // title, history button
              Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "My Activity",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                    InkWell(
                      onTap: () {
                        print("History");
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        child: Text(
                          "History",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              noTrips
                  ? Container(
                      padding: EdgeInsets.all(10),
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        'there is no completed Activity to show!',
                        style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 12,
                            color: Colors.grey.shade600),
                      ),
                    )
                  : ListView.separated(
                      itemBuilder: (BuildContext context, index) {
                        return HistoryItem(
                            history:
                                Provider.of<AppData>(context, listen: false)
                                    .tripHistoryDataList[index]);
                      },
                      separatorBuilder: (BuildContext context, index) =>
                          SizedBox(
                        height: 3,
                      ),
                      itemCount: Provider.of<AppData>(context, listen: false)
                          .tripHistoryDataList
                          .length,
                      padding: EdgeInsets.all(5),
                      physics: ClampingScrollPhysics(),
                      shrinkWrap: true,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
