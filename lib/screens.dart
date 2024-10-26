import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Medication.dart';
import 'MedicationRecord.dart';
import 'Database.dart';
import 'package:event_bus/event_bus.dart';
import 'package:intl/intl.dart';

EventBus eventBus = EventBus();

class UpdateMedicationsEvent {}

final Database database = Database();
final userId = FirebaseAuth.instance.currentUser!.uid;

class ScreenTwo extends StatefulWidget {
  const ScreenTwo({super.key});

  @override
  State<ScreenTwo> createState() => _screenTwoState();
}

class _screenTwoState extends State<ScreenTwo> {
  late List<Medication> medications = [];

  @override
  void initState() {
    super.initState();
    fetchMedicationsFromDatabase(); //medications will be fetched when the widget is created
    eventBus.on<UpdateMedicationsEvent>().listen((event) {
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

    //fetching the medications from the database
    for (var medication in fetchedMedications) {
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

    //updating the state variable
    setState(() {
      // medications = fetchedMedications;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
          itemCount: medications.length,
          itemBuilder: (context, index) {
            return Dismissible(
              key: Key(medications[index].id),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                if (direction == DismissDirection.endToStart) {
                  Medication medToBeDeleted = medications[index];
                  medications.removeAt(index);
                  setState(() {});
                  database.deleteMedicationForUser(userId, medToBeDeleted.id);
                }
              },

              //deleting the medication
              background: Container(
                color: Colors.grey,
                child: Icon(Icons.delete, color: Colors.white),
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20.0),
              ),

              child: Card(
                color: Color.fromARGB(221, 9, 9, 9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(height: 40),
                      Container(
                        height: 40,
                        child: GridView.count(
                          crossAxisCount: 4, //no of columns
                          childAspectRatio: 3,
                          physics: NeverScrollableScrollPhysics(),
                          children: <Widget>[
                            Container(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Name: ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          '${medications[index].medicationName}',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'time: ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '${medications[index].time}',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'dose: ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        '${medications[index].dose.toString()}',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'frequency: ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '${medications[index].freq}',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      //editing medications
                      Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            IconButton(
                                onPressed: () {
                                  //call a dialog to edit the medication
                                  _showEditMedicationDialog(
                                      context, medications[index]);
                                },
                                icon: Icon(Icons.edit,
                                    color: Colors.white, size: 20))
                          ])
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        Positioned(
            bottom: 16.0,
            left: 0.0,
            right: 0.0,
            child: Center(
              child: Container(
                width: 200,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    _showAddMedicationDialog(context);
                  },
                  backgroundColor: Colors.blue,
                  icon: Icon(Icons.add),
                  label: Text('Add a medication'),
                ),
              ),
            )),
      ],
    );
  }
}

//
//
//
//
//
//
//

//Adding medication dialog----------------------------------------------
void _showAddMedicationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // Create a TextEditingController for each input field
      TextEditingController medicationNameController = TextEditingController();
      TextEditingController medicationTimeController = TextEditingController();
      TextEditingController dosageController = TextEditingController();
      String? selectedDosageUnit;
      String? selectedFrequency;

      //Dropdown menu items for dosage units
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
      ];

      //dropdown menu items for frequency
      List<DropdownMenuItem<String>> frequencyOptions = [
        DropdownMenuItem(
            value: "daily",
            child: Text(
              "daily",
              style: TextStyle(color: Colors.grey),
            )),
        DropdownMenuItem(
            value: "one-time",
            child: Text(
              "one-time",
              style: TextStyle(color: Colors.grey),
            )),
      ];

      //--------------------------------------------------------------------------------

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title:
                Text('Add a Medication', style: TextStyle(color: Colors.white)),
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
                      //timepicker dialog
                      final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData.dark(),
                              child:
                                  child!, //THe theme only accepts nonnullable child
                            );
                          });

                      if (pickedTime != null) {
                        medicationTimeController.text =
                            pickedTime.format(context);
                      }
                    },
                    child: AbsorbPointer(
                      //preven keyboard from showing up
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
                  //frequency selector
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          dropdownColor: Colors.black,
                          value: selectedFrequency,
                          hint: Text("frequency",
                              style: TextStyle(color: Colors.grey)),
                          items: frequencyOptions,
                          onChanged: (value) {
                            setState(() {
                              selectedFrequency = value;
                            });
                          },
                        ),
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
                    'freq': selectedFrequency!,
                  });
                  // print(
                  //     'record $userId ${medicationNameController.text} ${medicationTimeController.text} ${dosageController.text} $selectedDosageUnit');
                  setState(() {
                    //update the medications widget
                    eventBus.fire(UpdateMedicationsEvent());
                  });
                  Navigator.of(context).pop(); //close
                },
              ),
            ],
          );
        },
      );
    },
  );
}

//editing medication dialog----------------------------------------------

void _showEditMedicationDialog(BuildContext context, Medication medication) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // Create a TextEditingController for each input field
      TextEditingController medicationNameController =
          TextEditingController(text: medication.medicationName);
      TextEditingController medicationTimeController =
          TextEditingController(text: medication.time);
      TextEditingController dosageController = TextEditingController(
          text: medication.dose.replaceAll(RegExp(r'[^0-9]'), ''));
      String? selectedDosageUnit =
          medication.dose.toString().replaceAll(RegExp(r'[0-9]'), '');
      String? selectedFrequency = medication.freq;

      //Dropdown menu items for dosage units
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
      ];

      //dropdown menu items for frequency
      List<DropdownMenuItem<String>> frequencyOptions = [
        DropdownMenuItem(
            value: "daily",
            child: Text(
              "daily",
              style: TextStyle(color: Colors.grey),
            )),
        DropdownMenuItem(
            value: "one-time",
            child: Text(
              "one-time",
              style: TextStyle(color: Colors.grey),
            )),
      ];

      //--------------------------------------------------------------------------------

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title:
                Text('Edit Medication', style: TextStyle(color: Colors.white)),
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
                      //timepicker dialog
                      final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData.dark(),
                              child:
                                  child!, //THe theme only accepts nonnullable child
                            );
                          });
                      // If a time is picked, update the TextField's controller
                      if (pickedTime != null) {
                        // Format and set the picked time as the TextField's text
                        medicationTimeController.text =
                            pickedTime.format(context);
                      }
                    },
                    child: AbsorbPointer(
                      //preven keyboard from showing up
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
                  //frequency selector
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          dropdownColor: Colors.black,
                          value: selectedFrequency,
                          hint: Text("frequency",
                              style: TextStyle(color: Colors.grey)),
                          items: frequencyOptions,
                          onChanged: (value) {
                            setState(() {
                              selectedFrequency = value;
                            });
                          },
                        ),
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
                  database.updateMedicationForUser(userId, medication.id, {
                    'medicationName': medicationNameController.text,
                    'time': medicationTimeController.text,
                    'dose': dosageController.text + selectedDosageUnit!,
                    'freq': selectedFrequency!,
                  });
                  // print(
                  //     'record $userId ${medicationNameController.text} ${medicationTimeController.text} ${dosageController.text} $selectedDosageUnit');
                  setState(() {
                    //update the medications widget
                    eventBus.fire(UpdateMedicationsEvent());
                  });
                  Navigator.of(context).pop(); //close
                },
              ),
            ],
          );
        },
      );
    },
  );
}

//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//

//screen-3
class ScreenThree extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: database.fetchMedicationsRecord(userId),
      builder: (BuildContext context,
          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Unexpected error"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No medications found"));
        }
        //converting and using fetched data
        List<Map<String, dynamic>> fetchedMedications = snapshot.data!;
        List<MedicationRecord> medicationRecords = fetchedMedications
            .map((record) => MedicationRecord.fromMap(record))
            .toList();
        medicationRecords.sort((b, a) =>
            a.takenTime.compareTo(b.takenTime)); //sorting from latest to oldest

        //printing the fetched data
        return CustomScrollView(
          slivers: [
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
                mainAxisExtent: 60,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(221, 9, 9, 9),
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                          //time conversions
                          "${DateFormat("MMMM d, y 'at' h:mm:ss a").format(medicationRecords[index].takenTime.toDate())}",
                          style: TextStyle(fontSize: 15, color: Colors.blue)),
                      subtitle: Row(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Aligns the row's children to the start, similar to ListTile's default alignment
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "${medicationRecords[index].medicationName}",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "Dosage: ${medicationRecords[index].dose}", // Example additional information
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "Frequency: ${medicationRecords[index].freq}", // Example additional information
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "Status: ${medicationRecords[index].status}", // Example additional information
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: medicationRecords.length,
              ),
            ),
          ],
        );
      },
    );
  }
}
