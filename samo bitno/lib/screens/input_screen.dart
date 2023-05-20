import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lorenloznik/TransactionModel.dart';
import 'package:lorenloznik/main.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InputPage extends StatefulWidget{
  @override
  State<InputPage> createState() => _InputPage();
}

class _InputPage extends State<InputPage>{
  final GlobalKey<FormState> _titleformKey = GlobalKey<FormState>();

  var _dropdownValue = "null";

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is PickerDateRange) {
        _range = '${DateFormat('dd/MM/yyyy').format(args.value.startDate)} -'
        // ignore: lines_longer_than_80_chars
            ' ${DateFormat('dd/MM/yyyy').format(args.value.endDate ?? args.value.startDate)}';
      } else if (args.value is DateTime) {
        _selectedDate = args.value;
      } else if (args.value is List<DateTime>) {
        _dateCount = args.value.length.toString();
      } else {
        _rangeCount = args.value.length.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Izradi trošak"),
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: ListView(
          children: [
          Form(
          key: _titleformKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(      /// Unos naziva troška
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Naziv troška',
                ),
                validator: (String? value) {      /// sluzi za provjeriti ako je ista uneseno u field
                  if (value == null || value.isEmpty) {
                    return 'Unesite tekst';
                  }
                  return null;
                },
              ),
              SfDateRangePicker(    /// unos datuma
                onSelectionChanged: _onSelectionChanged,
                selectionMode: DateRangePickerSelectionMode.single,
              ),
              TextFormField(      /// unos iznosa troska
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Iznos troška',
                ),
                validator: (String? value) {      /// sluzi za provjeriti ako je ista uneseno u field
                  if (value == null || value.isEmpty) {
                    return 'Unesite tekst';
                  }
                  return null;
                },
              ),
              TextFormField(      /// unos opisa troska
                controller: descriptionController,
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Opis troška',
                ),
                validator: (String? value) {       /// sluzi za provjeriti ako je ista uneseno u field
                  if (value == null || value.isEmpty) {
                    return 'Unesite tekst';
                  }
                  return null;
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownButton(
                      /// Padajuci izbornik sa mogucim opcijama
                      value: _dropdownValue,
                      items: const [
                        DropdownMenuItem(child: Text("Odaberite kategoriju"), value: "null",),
                        DropdownMenuItem(child: Text("Odjeća"), value: "Odjeća",),
                        DropdownMenuItem(child: Text("Hrana"), value: "Hrana",),
                        DropdownMenuItem(child: Text("Higijena"), value: "Higijena",),
                        DropdownMenuItem(child: Text("Tehnologija"), value: "Tehnologija",),
                        DropdownMenuItem(child: Text("Škola"), value: "Škola",),
                        DropdownMenuItem(child: Text("Režije"), value: "Režije",),
                      ], onChanged: (String? value) {
                      setState(() {
                        _dropdownValue = value!;
                      });
                    },
                    ),
                    ElevatedButton(

                      /// kad se botun za spremanje stisne
                      onPressed: () async {
                        var box = await Hive.openBox('transactions');

                        if (_titleformKey.currentState!.validate()) {    /// provjerava ako su svi podatci dobro uneseni
                          var key = Categories.keys.firstWhere((k) => Categories[k] == _dropdownValue, orElse: () => 0);      /// pretvara string kategorije u int zadan unutar TransactionModel.dart

                          /// Kreira transakciju u dobroj klasi
                          Transaction _newTransaction = Transaction(
                              titleController.text,
                              _selectedDate,
                              descriptionController.text,
                              double.parse(amountController.text),
                              key,
                          );

                          /// Stavlja transakciju u bazu podataka
                          /// ime je u formatu: danasnji datum + random string dugacak 20 slova
                          box.put(DateFormat('yyyy/MM/dd').format(_selectedDate)+getRandomString(20), _newTransaction);

                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Spremi'),
                    ),
                  ],
                ),
              )
            ],
          ),
        )
          ],
        ),
      ),
    );
  }


}
