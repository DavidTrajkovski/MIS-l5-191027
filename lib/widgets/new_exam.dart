import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../helpers/location_helper.dart';
import '../screens/choose_place_screen.dart';

class NewExam extends StatefulWidget {
  final Function addNewExamHandler;

  const NewExam({
    super.key,
    required this.addNewExamHandler,
  });

  @override
  State<NewExam> createState() => _NewExamState();
}

class _NewExamState extends State<NewExam> {
  final _subjectNameController = TextEditingController();
  final locationHelper = LocationHelper();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTimeStart;
  TimeOfDay? _selectedTimeEnd;
  LatLng? _location = null;
  String? _address = null;

  void _submitExam() {
    if (_subjectNameController.text.isEmpty) {
      return;
    }

    final String enteredSubjectName = _subjectNameController.text;

    if (enteredSubjectName.isEmpty ||
        _selectedDate == null ||
        _selectedTimeStart == null ||
        _selectedTimeEnd == null ||
        _location == null) {
      return;
    }

    widget.addNewExamHandler(enteredSubjectName, _selectedDate,
        _selectedTimeStart, _selectedTimeEnd, _location, _address);

    Navigator.of(context).pop();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2025),
    ).then((value) => {
          if (value != null)
            {
              setState(() {
                _selectedDate = value;
              })
            }
        });
  }

  void _presentTimePickerStart() {
    showTimePicker(
            context: context, initialTime: const TimeOfDay(hour: 0, minute: 0))
        .then((pickedTime) {
      if (pickedTime == null) {
        return;
      }
      setState(() {
        _selectedTimeStart = pickedTime;
      });
    });
  }

  void _presentTimePickerEnd() {
    showTimePicker(
            context: context, initialTime: const TimeOfDay(hour: 0, minute: 0))
        .then((pickedTime) {
      if (pickedTime == null) {
        return;
      }
      setState(() {
        _selectedTimeEnd = pickedTime;
      });
    });
  }

  void onMapTap(LatLng loc) {
    setState(() async {
      _location = loc;
      _address =
          await LocationHelper.getPlaceAddress(loc.latitude, loc.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 900,
        padding:
            const EdgeInsets.only(top: 10, bottom: 20, left: 10, right: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Subject Name'),
                controller: _subjectNameController,
                onSubmitted: (_) => _submitExam(),
              ),
              SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate == null
                          ? 'No Date Chosen!'
                          : 'Picked Date: ${DateFormat.yMMMd().format(_selectedDate!)}',
                    ),
                    TextButton(
                      onPressed: _presentDatePicker,
                      child: const Text(
                        'Choose Date',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        _selectedTimeStart == null
                            ? 'No Start Time Chosen!'
                            : 'Start time: ${_selectedTimeStart?.format(context)}',
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColor),
                      onPressed: _presentTimePickerStart,
                      child: const Text(
                        'Choose Start Time',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        _selectedTimeEnd == null
                            ? 'No End Time Chosen!'
                            : 'End Time: ${_selectedTimeEnd?.format(context)}',
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColor),
                      onPressed: _presentTimePickerEnd,
                      child: const Text(
                        'Choose End Time',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                  child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _location == null
                          ? 'No Location Chosen!'
                          : 'Location: $_address',
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChooseOnMap(
                                      onMapTap: onMapTap,
                                      initExamLoc: _location,
                                    )));
                      },
                      child: const Text(
                        "Select Location",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey),
                      )),
                ],
              )),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: ElevatedButton(
                  onPressed: _submitExam,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      Theme.of(context).secondaryHeaderColor,
                    ),
                  ),
                  child: const Text('Add Exam'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
