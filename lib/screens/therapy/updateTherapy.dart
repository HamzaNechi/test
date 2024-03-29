import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../utils/constants.dart';
import '../../utils/style.dart';
import 'map.dart';

class UpdateTherapy extends StatefulWidget {
 

  UpdateTherapy();

  @override
  _AddGroupTherapyScreenState createState() => _AddGroupTherapyScreenState();
}

class _AddGroupTherapyScreenState extends State<UpdateTherapy> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
    final TextEditingController _descController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  File? _image;
  LatLng? _location;
    late String email = '';
    DateTime lastDate = DateTime.now().add(Duration(days: 5*365));


  @override
  void initState() {
    super.initState();

  }



 Future<void> _selectLocation() async {
  final location = await Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => LocationPickerScreen()));
  if (location != null) {
    setState(() {
      _location = location;
    });
    
    try {
      final placemarks = await placemarkFromCoordinates(
        _location!.latitude,
        _location!.longitude,
      );
      _addressController.text = placemarks.first.street!;
    } catch (e) {
      print('Error while getting address: $e');
    }
  }
}


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: lastDate,
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat.yMd().format(_selectedDate);
      });
    }
  }

  Future<void> _submitForm() async {
  print("idddddddddddddd$email");
    if (_formKey.currentState!.validate()) {
    final uri = Uri.parse('$BASE_URL/therapy/updateTherapy');
final headers = {'Content-Type': 'multipart/form-data'};
final request = http.MultipartRequest('POST', uri);

// add form fields
request.fields['titre'] = _titleController.text;
request.fields['date'] = _selectedDate.toIso8601String();
request.fields['capacity'] = _capacityController.text;
request.fields['address'] = _addressController.text;
request.fields['description'] = _descController.text;
//hamza req
request.fields['type'] = type;
//end hamza req
request.fields['dispo'] = 'true';

if (_location != null) {
  request.fields['latitude'] = _location!.latitude.toString();
  request.fields['longitude'] = _location!.longitude.toString();
}

// add image file


// send the request
final response = await request.send();
if (response.statusCode == 200) {
  final parsedResponse = await response.stream.bytesToString();
  final newTherapy = json.decode(parsedResponse)['therapy'];
    
  // TODO: do something with the new therapy
} else {
  print("something went wrong");
}
    }
  }

  //en ligne hamza déclaration
  List<String> itemsType = ['face-to-face', 'Remotely'];
  String type = "face-to-face";
  bool enableAddress = false;
  //end déclaration hamza


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: const Text("Update your group therapy"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_rounded),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            
   Column(
    mainAxisAlignment: MainAxisAlignment.center,
     children: [
       GestureDetector(
  
  child: SizedBox(
        height: 200,
        child: _image != null
          ? Image.file(
              _image!,
              fit: BoxFit.cover,
            )
          : Image.asset(
              'Assets/50.png',
              fit: BoxFit.cover,
            ),
  ),
),

     ],
   ),
 SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
              hintText: "The title",
              prefixIcon: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Icon(Icons.title),
              ),
            ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              
              controller: _capacityController,
              decoration: InputDecoration(
              hintText: "the  capacity",
              prefixIcon: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the capacity';
                }
                if (double.tryParse(value) == null) {
                  return 'Capacity must be a number';
                }
                return null;
              },
            ),

            
            SizedBox(height: 16),

            GestureDetector(
              onTap: () {
                _selectDate(context);
              },
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _dateController,
                   decoration: InputDecoration(
              hintText: "the date",
              prefixIcon: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Icon(Icons.date_range),
              ),
            ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a date';
                    }
                    return null;
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
             TextFormField(
              controller: _descController,
              decoration: InputDecoration(
              hintText: "The description",
              prefixIcon: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Icon(Icons.description),
              ),
            ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an address';
                }
                return null;
              },
            ),
            //dropdown type hamza
                        SizedBox(height: 16),
                DropdownButtonFormField<String>(
                //hint
                items: itemsType
                    .map((item2) => DropdownMenuItem(
                        value: item2,
                        child: Text(item2, style: const TextStyle(fontSize: 15))))
                    .toList(),
                onChanged: (item2) => setState(() {
                  type = item2!;
                  if(type == "face-to-face"){
                    enableAddress = true;
                  }else{
                    enableAddress = false;
                  }
                }),
                decoration: const InputDecoration(
                  hintText: "Choose type",
                  prefixIcon: Icon(Icons.switch_left_rounded),
                ),
              ),
            // end dropdown hamza

            SizedBox(height: 16),

            Visibility(
                visible: enableAddress,
                child:TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                hintText: "The adress",
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.location_city_outlined),
                ),
              ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ), 
            ),
            
 
            Visibility(
              visible: enableAddress,
              child: SizedBox(
                height: 76,
                child: GestureDetector(
                onTap: _selectLocation,
                child: Image.asset(
                  'Assets/1234.png',
                  height: 60,
                  width: 100,
                ),
                          ),
              ),
              ),
           
           

   
            

            if (_location != null)
              SizedBox(
                height: 200,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _location!,
                    zoom: 16,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId('location'),
                      position: _location!,
                    ),
                  },
                ),
              ),



            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text(
                "Update your Therapy",
                style: TextStyle(
                    color: Style.whiteColor,
                    fontFamily: 'Mark-Light',
                    fontWeight: FontWeight.bold,
                    fontSize: 17),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
