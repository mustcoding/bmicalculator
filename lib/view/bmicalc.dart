import 'dart:math';
import 'package:flutter/material.dart';

import '../controller/sqlite_db.dart';

class bmicalc extends StatefulWidget {
  const bmicalc({super.key});

  @override
  State<bmicalc> createState() => _bmicalcState();
}

class _bmicalcState extends State<bmicalc> {

  String? selectedGender;
  double BMI = 0.0;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController bmiController = TextEditingController();

  void calculateBMI(){
    double weight = double.parse(weightController.text);
    double height = double.parse(heightController.text);
    String name = nameController.text;
    String gender = selectedGender?.toString() ?? '';
    String status='';


    setState(() {

      if(weight!=null && height!=null && name.isNotEmpty && gender.isNotEmpty){

        BMI = weight/((height/100)*(height/100));
        print("BMI: ${BMI}");
        if(gender == "Male"){

          if(BMI<18.5){
            status="Underweight. Careful during strong wind!";
          }
          else if(BMI>=18.5 && BMI<=24.9){
            status="That's ideal! Please maintain";
          }
          else if(BMI>=25.0 && BMI<=29.9){
            status="Overweight! Work out please";
          }
          else{
            status="Whoa Obese! Dangerous mate!";
          }
        }
        else if(gender == "Female"){

          if(BMI<16){
            status="Underweight. Careful during strong wind!";
          }
          else if(BMI>=16 && BMI<22){
            status="That's ideal! Please maintain";
          }
          else if(BMI>=22 && BMI<=26.9){
            status="Overweight! Work out please";
          }
          else{
            status="Whoa Obese! Dangerous mate!";
          }
        }
        bmiController.text= BMI.toStringAsFixed(2);
        _AlertMessage(status+ " \nYour BMI is: "+bmiController.text);

        Map<String, dynamic> dataToInsert = {
          'username': nameController.text,
          'weight': double.parse(weightController.text),
          'height': double.parse(heightController.text),
          'gender': selectedGender,
          'bmi_status': status,
        };
        SQLiteDB().insert('bmi', dataToInsert);

        nameController.clear();
        heightController.clear();
        weightController.clear();
        bmiController.clear();
        selectedGender=null;

      }else
      {
        _AlertMessage("Please Insert All Information Needed!!");
      }

    });

  }

  void _AlertMessage(String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Message"),
          content: Text(msg),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    retriveLastData(); // Call the function to fetch data when the widget is initialized
  }

  Future<void> retriveLastData() async {
    try {
      List<Map<String, dynamic>> result = await SQLiteDB().queryAll('bmi');
      if (result.isNotEmpty) {
        // Assuming the last inserted record is the first one in the result list
        Map<String, dynamic> lastData = result.last;

        setState(() {
          nameController.text = lastData['username'] ?? '';
          heightController.text = lastData['height'].toString() ?? '';
          weightController.text = lastData['weight'].toString() ?? '';
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Center(child: const Text('BMI Calculator',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),),
          backgroundColor: Colors.blue,),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Your Fullname',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: heightController,
                decoration: InputDecoration(
                  labelText: 'height in cm: 170',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: weightController,
                decoration: InputDecoration(
                  labelText: 'Weight in KG',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: bmiController,
                readOnly: true,
                decoration: const InputDecoration(
                    labelText: 'BMI Value'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Male'),
                      leading: Radio(
                        value: 'Male',
                        groupValue: selectedGender,
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value.toString();
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Female'),
                      leading: Radio(
                        value: 'Female',
                        groupValue: selectedGender,
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value.toString();
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height:20.0),
            ElevatedButton(
              onPressed: calculateBMI,
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // Set your desired background color here
              ),
              child: const Text('Calculate BMI and Save',
                  style: TextStyle(fontSize: 18.0,
                      fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
