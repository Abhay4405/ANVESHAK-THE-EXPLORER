import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class PersonFoundPage extends StatefulWidget {
  const PersonFoundPage({super.key});

  @override
  _PersonFoundPageState createState() => _PersonFoundPageState();
}

class _PersonFoundPageState extends State<PersonFoundPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController contactController = TextEditingController(); 

  File? _mobileImage;
  Uint8List? _webImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) {
      if (kIsWeb) {
        _webImage = await pickedFile.readAsBytes();
      } else {
        _mobileImage = File(pickedFile.path);
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = MediaQuery.of(context).size.width > 600;
    const double paddingValue = 20.0;
    final double formWidth = isWeb ? 600.0 : double.infinity;

    return Scaffold(
      appBar: AppBar(title: const Text('Report Person Found')),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(paddingValue),
          child: Container(
            width: formWidth,
            padding: EdgeInsets.all(isWeb ? 40 : 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 15, spreadRadius: 5),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Found Person Details (Database 2)',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(height: 25),
                  
                  _buildTextField('Full Name (if known)', nameController, Icons.person_pin),
                  const SizedBox(height: 15),
                  _buildTextField('Your Contact (for follow-up)', contactController, Icons.phone, TextInputType.phone),
                  const SizedBox(height: 15),
                  _buildTextField('Found Location', locationController, Icons.my_location),
                  const SizedBox(height: 15),
                  _buildDateField('Date Found', dateController, Icons.calendar_today),
                  const SizedBox(height: 30),

                  const Text('Upload Current Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildImagePickerButton(Icons.camera_alt, 'Camera', () => _pickImage(ImageSource.camera), context),
                      _buildImagePickerButton(Icons.photo, 'Gallery', () => _pickImage(ImageSource.gallery), context),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  Center(
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.5), width: 2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: kIsWeb
                          ? (_webImage != null
                              ? ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.memory(_webImage!, fit: BoxFit.cover))
                              : const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)))
                          : (_mobileImage != null
                              ? ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(_mobileImage!, fit: BoxFit.cover))
                              : const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey))),
                    ),
                  ),

                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Found Person Report Submitted! Awaiting Admin Review.')),
                          );
                          Navigator.pop(context); // Go back to Home
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // HELPER FUNCTIONS
  Widget _buildTextField(String label, TextEditingController controller, IconData icon, [TextInputType keyboardType = TextInputType.text]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor.withOpacity(0.7)),
      ),
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime.now());
        if (pickedDate != null) {
          controller.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
        }
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor.withOpacity(0.7)),
      ),
      validator: (value) => value!.isEmpty ? 'Please select $label' : null,
    );
  }

  Widget _buildImagePickerButton(IconData icon, String label, VoidCallback onPressed, BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Theme.of(context).colorScheme.primary),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        foregroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), width: 1),
        ),
      ),
    );
  }
}