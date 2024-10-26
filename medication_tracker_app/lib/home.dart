import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import 'Medication.dart';
import 'MedicationRecord.dart';
import 'Database.dart';
import 'screens.dart';
import 'package:event_bus/event_bus.dart';
import 'package:intl/intl.dart';

EventBus eventBus = EventBus();

class UpdateTimeslotsEvent {}

final Database database = Database();
final userId = FirebaseAuth.instance.currentUser!.uid;

List<Map> advices = [
  {
    'title': 'Consistency is key',
    'icon': Icons.schedule,
  },
  {
    'title': 'Stay hydrated! Drink a glass/ hour',
    'icon': Icons.health_and_safety,
  },
  {
    'title': 'Stay hydrated! Drink a glass/ hour',
    'icon': Icons.local_drink,
  },
  {
    'title': 'Set reminders to never miss a dose.',
    'icon': Icons.alarm,
  },
  {
    'title': 'Keep your medications in a visible spot',
    'icon': Icons.visibility,
  },
  {
    'title': 'Always consult your doctor',
    'icon': Icons.local_hospital,
  },
  {
    'title': 'Track side effects and report them',
    'icon': Icons.report_problem,
  },
  {'title': 'Double-check your prescriptions', 'icon': Icons.assignment},
];

class HomePage extends StatefulWidget {
  final String userData;
  HomePage({Key? key, required this.userData}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    //We can use widget.userData wherever needed to retreive the uid of the user

    //print('from home ${widget.userData}');

    return Scaffold(
      body: HomeScreen(),
    );
  }
}

//HomeScreen
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild the widget on tab change.
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Medications', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          timeSlot(), // Screen for the first tab
          ScreenTwo(), // Screen for the second tab
          ScreenThree(),
        ],
      ),
      bottomNavigationBar: Material(
        color: Colors.black,
        child: TabBar(
          controller: _tabController, // Use the custom TabController.
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.white,
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          indicatorColor: Colors.transparent,
          indicatorWeight: 5,
          tabs: [
            Tab(
              icon: Icon(Icons.today),
            ),
            Tab(
              icon: ImageIcon(
                AssetImage('pills-bottle.png'),
                color: _tabController.index == 1 ? Colors.blue : Colors.white,
              ),
            ),
            Tab(
              icon: Icon(Icons.medical_services),
            ),
          ],
        ),
      ),
      floatingActionButton: _tabController?.index == 0
          ? FloatingActionButton(
              onPressed: () {
                _showAddMedicationDialog(context);
              },
              backgroundColor: Colors.lightBlue,
              child: Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}

//Time slots

class timeSlot extends StatefulWidget {
  const timeSlot({super.key});

  @override
  State<timeSlot> createState() => _timeSlotState();
}

class _timeSlotState extends State<timeSlot> {
  late List<Medication> medications = [];

  @override
  void initState() {
    super.initState();
    fetchMedicationsFromDatabase(); //medications will be fetched when the widget is created
    eventBus.on<UpdateTimeslotsEvent>().listen((event) {
      //
      setState(() {
        fetchMedicationsFromDatabase();
      });
    });
  }

  void fetchMedicationsFromDatabase() async {
    medications = [];
    final DateFormat timeFormat = DateFormat.jm(); //AM/pm format
    //fetching the medications from the database
    List<Map<String, dynamic>> fetchedMedications =
        await database.fetchMedicationsForUser(userId);

    List<Map<String, dynamic>> fetchedMedicationsRecords =
        await database.fetchMedicationsRecord(userId);

    //convert the list of maps to a list of MedicationRecord objects
    List<MedicationRecord> medicationRecords = fetchedMedicationsRecords
        .map((record) => MedicationRecord.fromMap(record))
        .toList();

    List<MedicationRecord> takenTodayRecords =
        medicationRecords.where((record) => record.isTakenToday()).toList();

    List<String> takenTodayIds =
        takenTodayRecords.map((record) => record.medicationId).toList();

    //filter fetchedMedications to include only those not taken today
    List<Map<String, dynamic>> medicationsNotTakenToday =
        fetchedMedications.where((medication) {
      return !takenTodayIds.contains(medication['id']);
    }).toList();

    //fetching the medications from the database
    for (var medication in medicationsNotTakenToday) {
      medications.add(
        Medication(
            id: medication['id'],
            time: medication['time'],
            medicationName: medication['medicationName'],
            dose: medication['dose'],
            freq: medication['freq']),
      );
    }

    //to sort the medications by time
    medications.sort((a, b) {
      final timeA = timeFormat.parse(a.time);
      final timeB = timeFormat.parse(b.time);
      return timeA.compareTo(timeB);
    });

    // updating the state variable
    setState(() {
      // medications = fetchedMedications;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            height: 100,
            child: ListView.builder(
              itemCount: advices.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Container(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Card(
                      color: Colors.blue,
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Center(
                              child: Column(
                                children: [
                                  Icon(advices[index]['icon'],
                                      color: Colors.white, size: 20),
                                  SizedBox(height: 5),
                                  Text(
                                    "${advices[index]['title']}",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              //
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return Dismissible(
                key: Key(medications[index].id),
                onDismissed: (direction) {
                  if (direction == DismissDirection.startToEnd) {
                    // The widget was dismissed to the right (confirming)
                    Medication medToBeConfirmed = medications[index];
                    medications.removeAt(index);
                    setState(() {});
                    database.recordTakenTimeIntoDatabase(
                        userId, medToBeConfirmed.id, {
                      'medicationName': medToBeConfirmed.medicationName,
                      'takenTime': DateTime.now(),
                      'dose': medToBeConfirmed.dose,
                      'freq': medToBeConfirmed.freq,
                      'medicationId': medToBeConfirmed.id,
                      'status': 'confirmed'
                    });
                  } else if (direction == DismissDirection.endToStart) {
                    //the widget was dismissed to the left (skipping)
                    Medication medToBeSkipped = medications[index];
                    medications.removeAt(index);
                    setState(() {});
                    database.recordTakenTimeIntoDatabase(
                        userId, medToBeSkipped.id, {
                      'medicationName': medToBeSkipped.medicationName,
                      'takenTime': DateTime.now(),
                      'dose': medToBeSkipped.dose,
                      'freq': medToBeSkipped.freq,
                      'medicationId': medToBeSkipped.id,
                      'status': 'skipped'
                    });
                  }
                },
                background: Container(
                  color: Colors.green,
                  child: Icon(Icons.check, color: Colors.white),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 20.0),
                ),
                secondaryBackground: Container(
                  color: Colors.grey,
                  child: Icon(Icons.delete, color: Colors.white),
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20.0),
                ),
                child: Card(
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          medications[index].time,
                          style: TextStyle(
                            color: Colors.lightBlue,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Row(
                          children: <Widget>[
                            Text(
                              medications[index].medicationName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                            ),
                            SizedBox(width: 25.0),
                            Text(
                              medications[index].dose.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                            ),
                            SizedBox(height: 40.0),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            childCount: medications.length,
          ),
        ),
      ],
    );
  }
}

void _showAddMedicationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      TextEditingController medicationNameController = TextEditingController();
      TextEditingController medicationTimeController = TextEditingController();
      TextEditingController dosageController = TextEditingController();
      String? selectedDosageUnit;
      List<DropdownMenuItem<String>> dosageUnits = [
        DropdownMenuItem(
            value: "mg",
            child: Text(
              "mg",
              style: TextStyle(color: Colors.grey),
            )),
        DropdownMenuItem(
            value: "g",
            child: Text(
              "g",
              style: TextStyle(color: Colors.grey),
            )),
        DropdownMenuItem(
            value: "ml",
            child: Text(
              "ml",
              style: TextStyle(color: Colors.grey),
            )),
        // Add more units as needed
      ];

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Add one-time Medication',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.black,
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: medicationNameController,
                    decoration: InputDecoration(
                      hintText: "Medication Name",
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),

                  //time selector
                  GestureDetector(
                    onTap: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData.dark(), // set the theme to dark
                              child:
                                  child!, //THe theme only accepts nonnullable child
                            );
                          });
                      // if a time is picked, update the TextField's controller
                      if (pickedTime != null) {
                        //format and set the picked time as the TextField's text
                        medicationTimeController.text =
                            pickedTime.format(context);
                      }
                    },
                    child: AbsorbPointer(
                      // prevent the keyboard from showing
                      child: TextField(
                        controller: medicationTimeController,
                        decoration: InputDecoration(
                          hintText: "Time",
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: dosageController,
                          decoration: InputDecoration(
                            hintText: "Dosage",
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(
                          width:
                              10), // Add some spacing between the text field and dropdown
                      DropdownButton<String>(
                        dropdownColor: Colors.black,
                        value: selectedDosageUnit,
                        hint:
                            Text("unit", style: TextStyle(color: Colors.grey)),
                        items: dosageUnits,
                        onChanged: (value) {
                          setState(() {
                            selectedDosageUnit = value;
                          }); // select the unit
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Add'),
                onPressed: () {
                  //db
                  database.addMedicationForUser(userId, {
                    'medicationName': medicationNameController.text,
                    'time': medicationTimeController.text,
                    'dose': dosageController.text + selectedDosageUnit!,
                    'freq': 'one-time'
                  });
                  print(
                      'record $userId ${medicationNameController.text} ${medicationTimeController.text} ${dosageController.text} $selectedDosageUnit');
                  setState(() {
                    //update the timeslot widget
                    eventBus.fire(UpdateTimeslotsEvent());
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    },
  );
}
